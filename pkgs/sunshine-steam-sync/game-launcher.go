package main

import (
	"bufio"
	"fmt"
	"log"
	"net"
	"os"
	"os/exec"
	"os/signal"
	"strings"
	"syscall"
)

const socketPath = "/run/user/1000/sunshine-game-launcher.sock"

func launchGame(appID string) error {
	cmd := exec.Command("steam", "-applaunch", appID)
	if err := cmd.Start(); err != nil {
		return fmt.Errorf("failed to start game %s: %w", appID, err)
	}
	log.Printf("Launched game %s (PID: %d)", appID, cmd.Process.Pid)
	return nil
}

func handleConnection(conn net.Conn) {
	defer conn.Close()

	scanner := bufio.NewScanner(conn)
	for scanner.Scan() {
		appID := strings.TrimSpace(scanner.Text())
		if appID == "" {
			continue
		}

		log.Printf("Received request to launch game: %s", appID)

		if err := launchGame(appID); err != nil {
			log.Printf("Error launching game: %v", err)
			fmt.Fprintf(conn, "ERROR: %v\n", err)
		} else {
			fmt.Fprintf(conn, "OK: Launched game %s\n", appID)
		}
	}

	if err := scanner.Err(); err != nil {
		log.Printf("Error reading from connection: %v", err)
	}
}

func main() {
	// Remove existing socket if it exists
	os.Remove(socketPath)

	// Create Unix socket
	listener, err := net.Listen("unix", socketPath)
	if err != nil {
		log.Fatalf("Failed to create Unix socket: %v", err)
	}
	defer listener.Close()
	defer os.Remove(socketPath)

	// Set socket permissions
	if err := os.Chmod(socketPath, 0600); err != nil {
		log.Fatalf("Failed to set socket permissions: %v", err)
	}

	log.Printf("Game launcher daemon started, listening on %s", socketPath)

	// Handle signals for graceful shutdown
	go func() {
		sigChan := make(chan os.Signal, 1)
		signal.Notify(sigChan, syscall.SIGTERM, syscall.SIGINT)
		<-sigChan
		log.Println("Received shutdown signal, cleaning up...")
		listener.Close()
		os.Remove(socketPath)
		os.Exit(0)
	}()

	// Accept connections
	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Printf("Error accepting connection: %v", err)
			continue
		}

		go handleConnection(conn)
	}
}
