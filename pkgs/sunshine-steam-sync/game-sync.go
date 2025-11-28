package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"time"
)

type SunshineApp struct {
	Name      string `json:"name"`
	Cmd       string `json:"cmd,omitempty"`
	ImagePath string `json:"image-path,omitempty"`
}

type SunshineConfig struct {
	Apps []SunshineApp     `json:"apps"`
	Env  map[string]string `json:"env,omitempty"`
}

type SteamGridDBGame struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

type SteamGridDBImage struct {
	URL string `json:"url"`
}

type SteamGridDBResponse struct {
	Success bool                   `json:"success"`
	Data    []SteamGridDBImage     `json:"data"`
}

// fetchCoverArt fetches cover art from SteamGridDB for a given Steam App ID
func fetchCoverArt(apiKey, appID, cacheDir string) (string, error) {
	if apiKey == "" {
		return "", nil
	}

	// Check if image already exists in cache
	cachedImage := filepath.Join(cacheDir, appID+".png")
	if _, err := os.Stat(cachedImage); err == nil {
		return cachedImage, nil
	}

	// Fetch from SteamGridDB API
	url := fmt.Sprintf("https://www.steamgriddb.com/api/v2/grids/steam/%s?styles=alternate", appID)
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return "", err
	}
	req.Header.Set("Authorization", "Bearer "+apiKey)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return "", nil
	}

	var sgdbResp SteamGridDBResponse
	if err := json.NewDecoder(resp.Body).Decode(&sgdbResp); err != nil {
		return "", err
	}

	if !sgdbResp.Success || len(sgdbResp.Data) == 0 {
		return "", nil
	}

	// Download the first image
	imageURL := sgdbResp.Data[0].URL
	imgResp, err := http.Get(imageURL)
	if err != nil {
		return "", err
	}
	defer imgResp.Body.Close()

	// Save to cache
	os.MkdirAll(cacheDir, 0755)
	outFile, err := os.Create(cachedImage)
	if err != nil {
		return "", err
	}
	defer outFile.Close()

	if _, err := io.Copy(outFile, imgResp.Body); err != nil {
		return "", err
	}

	return cachedImage, nil
}

// parseVDF parses a simple VDF file and returns key-value pairs
func parseVDF(content string) map[string]string {
	result := make(map[string]string)
	re := regexp.MustCompile(`"([^"]+)"\s+"([^"]+)"`)
	matches := re.FindAllStringSubmatch(content, -1)
	for _, match := range matches {
		if len(match) == 3 {
			result[match[1]] = match[2]
		}
	}
	return result
}

// findSteamLibraries finds all Steam library paths from libraryfolders.vdf
func findSteamLibraries(steamPath string) ([]string, error) {
	vdfPath := filepath.Join(steamPath, "steamapps", "libraryfolders.vdf")
	content, err := os.ReadFile(vdfPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read libraryfolders.vdf: %w", err)
	}

	libraries := []string{steamPath} // Default library
	data := parseVDF(string(content))

	// Look for "path" entries in the VDF
	for key, value := range data {
		if key == "path" {
			libraries = append(libraries, value)
		}
	}

	return libraries, nil
}

// isSteamSystemApp returns true if the app name is a Steam system component
func isSteamSystemApp(name string) bool {
	systemPatterns := []string{
		"Proton",
		"Steam Linux Runtime",
		"Steamworks Common Redistributables",
		"Steam Runtime",
		"SteamVR",
	}

	for _, pattern := range systemPatterns {
		matched, _ := regexp.MatchString("(?i)"+pattern, name)
		if matched {
			return true
		}
	}
	return false
}

// getInstalledGames scans Steam libraries and returns installed games
func getInstalledGames(libraries []string, apiKey, cacheDir string) []SunshineApp {
	var games []SunshineApp
	seen := make(map[string]bool)

	for _, library := range libraries {
		steamappsPath := filepath.Join(library, "steamapps")
		pattern := filepath.Join(steamappsPath, "appmanifest_*.acf")

		matches, err := filepath.Glob(pattern)
		if err != nil {
			continue
		}

		for _, manifestPath := range matches {
			content, err := os.ReadFile(manifestPath)
			if err != nil {
				continue
			}

			data := parseVDF(string(content))
			gameName := data["name"]
			appid := data["appid"]

			if gameName != "" && appid != "" && !seen[gameName] && !isSteamSystemApp(gameName) {
				app := SunshineApp{
					Name: gameName,
					Cmd:  fmt.Sprintf("sunshine-game-client %s", appid),
				}

				// Fetch cover art
				if imagePath, err := fetchCoverArt(apiKey, appid, cacheDir); err == nil && imagePath != "" {
					app.ImagePath = imagePath
				}

				games = append(games, app)
				seen[gameName] = true
			}
		}
	}

	return games
}

// mergeConfigs merges static apps with Steam games
func mergeConfigs(staticPath, outputPath, apiKey, cacheDir string) error {
	// Read static config
	var staticConfig SunshineConfig
	staticData, err := os.ReadFile(staticPath)
	if err != nil {
		return fmt.Errorf("failed to read static config: %w", err)
	}

	if err := json.Unmarshal(staticData, &staticConfig); err != nil {
		return fmt.Errorf("failed to parse static config: %w", err)
	}

	// Find Steam installation
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("failed to get home directory: %w", err)
	}

	steamPath := filepath.Join(homeDir, ".steam", "steam")
	if _, err := os.Stat(steamPath); os.IsNotExist(err) {
		steamPath = filepath.Join(homeDir, ".local", "share", "Steam")
	}

	// Get Steam libraries and games
	libraries, err := findSteamLibraries(steamPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Warning: failed to find Steam libraries: %v\n", err)
		libraries = []string{}
	}

	steamGames := getInstalledGames(libraries, apiKey, cacheDir)

	// Merge: static apps first, then Steam games
	mergedConfig := SunshineConfig{
		Apps: append(staticConfig.Apps, steamGames...),
		Env:  staticConfig.Env,
	}

	// Write merged config
	outputData, err := json.MarshalIndent(mergedConfig, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal output: %w", err)
	}

	// Ensure output directory exists
	outputDir := filepath.Dir(outputPath)
	if err := os.MkdirAll(outputDir, 0755); err != nil {
		return fmt.Errorf("failed to create output directory: %w", err)
	}

	if err := os.WriteFile(outputPath, outputData, 0644); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	fmt.Printf("Successfully merged %d static apps and %d Steam games\n",
		len(staticConfig.Apps), len(steamGames))

	return nil
}

func main() {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	staticPath := filepath.Join(homeDir, ".config", "sunshine", "apps-static.json")
	outputPath := filepath.Join(homeDir, ".config", "sunshine", "apps.json")
	cacheDir := filepath.Join(homeDir, ".cache", "sunshine-covers")

	// Read configuration from environment variables
	if envStatic := os.Getenv("SUNSHINE_STATIC_APPS"); envStatic != "" {
		staticPath = envStatic
	}
	if envOutput := os.Getenv("SUNSHINE_APPS_OUTPUT"); envOutput != "" {
		outputPath = envOutput
	}
	if envCache := os.Getenv("SUNSHINE_COVER_CACHE"); envCache != "" {
		cacheDir = envCache
	}

	// Optional: SteamGridDB API key for cover art
	apiKey := os.Getenv("STEAMGRIDDB_API_KEY")
	if apiKey == "" {
		fmt.Println("No STEAMGRIDDB_API_KEY set, skipping cover art download")
	}

	if err := mergeConfigs(staticPath, outputPath, apiKey, cacheDir); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
