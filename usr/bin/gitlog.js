#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');

// Constants
const VERSION = "1.0.0";
const CONFIG_DIR = path.join(process.env.HOME || process.env.USERPROFILE, '.config/gitlog');
const CONFIG_FILE = path.join(CONFIG_DIR, 'setting.conf');
const OUTPUT_BASE_DIR = path.join(process.env.HOME || process.env.USERPROFILE, '.logs/gitlog');

// Utility Functions
const printVersion = () => {
  console.log(`gitlog.js version ${VERSION}`);
};

const printHelp = () => {
  console.log(`
Usage: gitlog.js [options]
Options:
  -h, --help           Show this help message and exit
  -v, --version        Show version number
  -g, --generate       Generate log files
    --author           Specify the author (optional, overrides config)
    --since            Specify the date since when to generate logs (optional, overrides config)
    --list             Specify the repository list to read from
  `);
};

const loadConfig = () => {
  if (!fs.existsSync(CONFIG_FILE)) {
    console.error(`ERROR: Config file not found: ${CONFIG_FILE}`);
    process.exit(1);
  }
  const configContent = fs.readFileSync(CONFIG_FILE, 'utf-8');
  const config = {};
  configContent.split('\n').forEach(line => {
    const [key, value] = line.split('=');
    if (key && value) {
      config[key.trim()] = value.trim();
    }
  });
  return config;
};

const loadRepositories = (repoList) => {
  const repoFile = path.join(CONFIG_DIR, 'repositories', `${repoList}.json`);
  if (!fs.existsSync(repoFile)) {
    console.error(`Repository config not found: ${repoFile}`);
    process.exit(1);
  }
  return JSON.parse(fs.readFileSync(repoFile, 'utf-8'));
};

const generateLog = (author, since, repoList) => {
  const outputDir = path.join(OUTPUT_BASE_DIR, author, since);
  fs.mkdirSync(outputDir, { recursive: true });

  const repos = loadRepositories(repoList);

  console.log(`Generating logs for ${author} since ${since}`);
  console.log(`Logs will be saved in ${outputDir}`);

  repos.forEach(repo => {
    const repoName = path.basename(repo);
    const outputFile = path.join(outputDir, `${repoName}.txt`);

    const gitCommand = `git -C ${repo} log --author="${author}" --since="${since}"`;

    exec(gitCommand, (error, stdout, stderr) => {
      if (error) {
        console.error(`Error processing ${repoName}: ${stderr}`);
        return;
      }
      fs.writeFileSync(outputFile, stdout);
      console.log(`Log for ${repoName} saved to ${outputFile}`);
    });
  });
};

// Main Logic
const argv = yargs(hideBin(process.argv))
  .option('help', { alias: 'h', type: 'boolean', description: 'Show help message' })
  .option('version', { alias: 'v', type: 'boolean', description: 'Show version' })
  .option('generate', { alias: 'g', type: 'boolean', description: 'Generate log files' })
  .option('author', { type: 'string', description: 'Specify the author' })
  .option('since', { type: 'string', description: 'Specify the start date' })
  .option('list', { type: 'string', description: 'Specify the repository list' })
  .argv;

if (argv.help) {
  printHelp();
} else if (argv.version) {
  printVersion();
} else if (argv.generate) {
  const config = loadConfig();
  const author = argv.author || config.author;
  const since = argv.since || config.since;
  const repoList = argv.list || config.repo_list;

  if (!author || !since || !repoList) {
    console.error('Missing required parameters. Use --help for usage.');
    process.exit(1);
  }

  generateLog(author, since, repoList);
} else {
  console.log('No options provided. Use --help for usage.');
}
