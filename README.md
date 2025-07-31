# 🛠️ Sablier Devkit

This repository contains configuration files and reusable scripts for various Sablier repositories.

The files are meant to be extended and customized as needed.

## ⚙️ Config Files

| Tool            | Config File                           |
| --------------- | :------------------------------------ |
| 🔍 Biome        | [`biome.jsonc`](./biome.jsonc)        |
| 📝 EditorConfig | [`.editorconfig`](./.editorconfig)    |
| ✨ Prettier     | [`prettier.json`](./.prettierrc.json) |

## 🤖 GitHub Actions

The [setup](./actions/setup/) GitHub Actions workflow is used to setup the requisite dependencies in a GitHub CI
workflow.

## 🛠️ Just CLI

This repo provides reusable Just files under the [just](./just) directory.

## 🚀 Setup Script

This is meant to be run by Sablier Labs employees and staff.

See [`setup.sh`](./shell/setup.sh) for details.

## 📦 VSCode Settings

See [`vscode/settings.json`](./vscode/settings.json).

## 📄 License

This project is licensed under MIT.
