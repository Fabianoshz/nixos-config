package main

import (
	"fmt"
	"net"
	"os"
)

const socketPath = "/run/user/1000/sunshine-game-launcher.sock"

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s <appid>\n", os.Args[0])
		os.Exit(1)
	}

	appID := os.Args[1]

	conn, err := net.Dial("unix", socketPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to connect: %v\n", err)
		os.Exit(1)
	}
	defer conn.Close()

	if _, err := fmt.Fprintf(conn, "%s\n", appID); err != nil {
		fmt.Fprintf(os.Stderr, "Failed to send: %v\n", err)
		os.Exit(1)
	}

	buf := make([]byte, 256)
	n, _ := conn.Read(buf)
	fmt.Printf("%s", buf[:n])
}
