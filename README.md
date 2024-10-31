# Gitlog

**Gitlog** is a command-line tool that generates Git log reports across multiple repositories. Designed to simplify your workflow, `gitlog` automatically collects commit data for a specific author over a defined time period.

## Features

-   Collects Git logs across multiple repositories.
-   Filters commits by author and time range.
-   Outputs logs to organized text files.
-   Includes autocompletion for command-line options.

## Table of Contents

-   [Installation](#installation)
-   [Configuration](#configuration)
-   [Usage](#usage)
-   [Examples](#examples)
-   [License](#license)

## Installation

You can install `gitlog` by either running the installation script or by downloading the `.deb` package.

### Option 1: Install via `.deb` Package (Recommended)

Download the latest `.deb` package from the [releases page](https://github.com/caesar003/gitlog/releases) of this repository and install it using:

```bash
sudo dpkg -i gitlog*.deb
```

### Option 2: Install via Installation Script

Clone the repository and run the provided installation script:

```bash
git clone https://github.com/caesar003/gitlog.git
cd gitlog
chmod +x install.sh
sudo ./install.sh
```

### Requirements

-   Git
-   Bash
-   Root privileges (for installation)

## Configuration

### Main Configuration

The main configuration file is located at `~/.config/gitlog/setting.conf`. Here you can set default parameters such as the repository, author, and starting date:

```conf
# ~/.config/gitlog/setting.conf
repository=sample
author=superadmin
since=2022-10-01
```

### Repository List

Each repository you want to include in the logs should be listed in JSON files within `~/.config/gitlog/repositories/`. Each JSON file should contain the list of repository paths:

```jsonc
// ~/.config/gitlog/repositories/sample.json
["path/to/first/repo", "path/to/second/repo", "path/to/additional/repo"]
```

## Usage

Run `gitlog` with various options to generate logs or view help information.

```bash
gitlog [OPTIONS]
```

### Options

-   `-h, --help` : Display help message.
-   `-v, --version` : Show the version number of `gitlog`.
-   `-g, --generate` : Generate Git logs based on the provided configuration.
    -   `-a, --author` : Specify the author name.
    -   `-s, --since` : Set the start date in `YYYY-MM-DD` format.
    -   `-n, --name` : Define the repository configuration file to use.

## Examples

Generate a report for `superadmin` from `2022-10-01` using the default repository list:

```bash
gitlog --generate --author "superadmin" --since "2022-10-01"
```

Specify a custom repository configuration:

```bash
gitlog --generate --name "sample"
```

Display help information:

```bash
gitlog --help
```

## File Structure

-   `bin/` : Contains the main `gitlog` executable.
-   `config/` : Default configuration files.
    -   `repositories/` : JSON files listing repositories.
-   `share/` : Man page and completion script.
    -   `bash-completion/` : Bash completion script for `gitlog`.
    -   `man/` : Man page file for `gitlog`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

---

Developed by [caesar003](https://github.com/caesar003)
