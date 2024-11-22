#!/usr/bin/env python3

import os
import argparse
import json
import subprocess
from pathlib import Path

# Constants
VERSION = "1.0.4"
CONFIG_DIR = os.path.expanduser("~/.config/gitlog")
CONFIG_FILE = os.path.join(CONFIG_DIR, "setting.conf")
OUTPUT_BASE_DIR = os.path.expanduser("~/.logs/gitlog")

def print_version():
    print(f"gitlog.py version {VERSION}")

def print_help():
    print("""
Usage: gitlog.py [options]
Options:
  -h, --help           Show this help message and exit
  -v, --version        Show version number
  -g, --generate       Generate log files
    -a, --author       Specify the author (optional, overrides config)
    -s, --since        Specify the date since when to generate logs (optional, overrides config)
    -l, --list         Specify the repository list to read from
    """)

def load_config():
    if not os.path.exists(CONFIG_FILE):
        print(f"ERROR: Config file not found: {CONFIG_FILE}")
        exit(1)
    with open(CONFIG_FILE, "r") as f:
        config = {}
        for line in f:
            key, _, value = line.partition("=")
            config[key.strip()] = value.strip()
    return config.get("author", ""), config.get("since", ""), config.get("repo_list", "")

def load_repositories(repo_list):
    repo_file = os.path.join(CONFIG_DIR, "repositories", f"{repo_list}.json")
    if not os.path.exists(repo_file):
        print(f"Repository config not found: {repo_file}")
        exit(1)
    with open(repo_file, "r") as f:
        return json.load(f)

def generate_log(author, since, repo_list):
    if not author or not since or not repo_list:
        author, since, repo_list = load_config()
    
    output_dir = os.path.join(OUTPUT_BASE_DIR, author, since)
    os.makedirs(output_dir, exist_ok=True)
    repo_paths = load_repositories(repo_list)
    
    print(f"Generating report for {author} starting from {since}")
    print(f"Log files will be saved in {output_dir}")
    
    for repo in repo_paths:
        repo_name = os.path.basename(repo)
        output_file = os.path.join(output_dir, f"{repo_name}.txt")
        try:
            result = subprocess.run(
                ["git", "-C", repo, "log", f"--since={since}", f"--author={author}"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            )
            if result.returncode == 0:
                with open(output_file, "w") as f:
                    f.write(result.stdout)
                print(f"Log for {repo_name} saved to {output_file}")
            else:
                print(f"Error for repository {repo_name}: {result.stderr}")
        except FileNotFoundError:
            print("Git is not installed or not found in PATH.")
            exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("-h", "--help", action="store_true", help="Show help message")
    parser.add_argument("-v", "--version", action="store_true", help="Show version")
    parser.add_argument("-g", "--generate", action="store_true", help="Generate logs")
    parser.add_argument("-a", "--author", help="Specify the author (optional)")
    parser.add_argument("-s", "--since", help="Specify the start date (optional)")
    parser.add_argument("-l", "--list", help="Specify the repository list")
    args = parser.parse_args()

    if args.help:
        print_help()
        exit(0)
    if args.version:
        print_version()
        exit(0)
    if args.generate:
        generate_log(args.author, args.since, args.list)
        exit(0)

    print("No options provided. Use -h for help.")
    exit(1)
