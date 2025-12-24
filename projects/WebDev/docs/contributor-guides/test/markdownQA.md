# How to check format, grammar, and spelling of markdown files in a GitHub project repository

Ensuring that Markdown files remain well-formatted, grammatically correct, and free of spelling errors proves essential for maintaining a high-quality project repository. Use the following to check the format, grammar, and spelling of Markdown files using [`markdownlint-cli`](https://github.com/igorshubovych/markdownlint-cli/tree/master) and [`Vale`](https://vale.sh/).

## Setup Information

The project [`devcontainer.json`](/.devcontainer/devcontainer.json) sets up the tools `markdownlint-cli` and `Vale`. Use the development container as configured.

## Step 1: Lint markdown files

Lint the project Markdown files by running the following command in the root directory of the repository:

```bash
markdownlint -f "**/*.md"
```

This command checks all Markdown files in the repository and reports any formatting issues based on the [CommonMark](https://commonmark.org/) specification and rules excluded in [`.markdownlint.yaml`](/.markdownlint.yaml). The command attempts to fix any formatting issues it can. Ignored files and directories get identified in [`.markdownlintignore`](/.markdownlintignore)

### Success criteria

markdownlint-cli provides an exit code of 0.

## Step 2: Check grammar and spelling

To check the grammar and spelling of your Markdown files, run the following command in the root directory of your repository:

```bash
vale . 
```

This command checks all files in the repository and reports any grammar and spelling issues based on the rules defined in [`.vale.ini`](/.vale.ini). For more information on using Vale check the [official documentation](https://vale.sh/docs/cli).

### Success criteria

Vale outputs 0 for suggestions, warnings, and errors.

## Conclusion

By following these steps, you can ensure that your Markdown files remain well-formatted, grammatically correct, and free of spelling errors. This helps maintain the quality and readability of your project repository.😄
