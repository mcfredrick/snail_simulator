# Snail Simulator

Snails are the artists of the mollusk world.

## Prerequisites

- [Godot Engine 4.5.1](https://godotengine.org/download)
- Git
- GitHub account

## Getting Started

1. **Create a new repository**
   - Create a new repository on GitHub
   - Clone it to your local machine

2. **Initialize with Copier**
   ```bash
   pip install copier
   copier gh:yourusername/crap-games-template .
   ```
   Answer the prompts to configure your game.

3. **Set up your Godot project**
   - Create a new Godot project in the `godot_web_game` directory
   - Configure your export presets for Web platform
   - Make sure to set the export path to `res://build/web/index.html`

4. **Commit and push**
   ```bash
   git add .
   git commit -m "Initial commit"
   git push -u origin main
   ```

## Development

### Local Development

1. **Run the game locally**
   - Open the project in Godot
   - Press F5 to run the game in the editor

2. **Export for Web**
   ```bash
   ./export_web.sh
   ```
   This will create a web build in `godot_web_game/build/web/`

### GitHub Actions

This project includes GitHub Actions workflows for:

- **Deploy Web Build**: Automatically builds and deploys the game to GitHub Pages on push to `main`
- **Register Game**: Registers the game with the Crap Games registry

## Deployment

The game will be automatically deployed to `https://snailsim.crap.games` when you push to the `main` branch.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
