function __fish_ollama_no_subcommand
    set -l cmd (commandline -opc)
    if [ (count $cmd) -eq 1 ]
        return 0
    end
    return 1
end

# Main commands
complete -c ollama -f -n __fish_ollama_no_subcommand -a serve -d 'Start ollama'
complete -c ollama -f -n __fish_ollama_no_subcommand -a create -d 'Create a model from a Modelfile'
complete -c ollama -f -n __fish_ollama_no_subcommand -a show -d 'Show information for a model'
complete -c ollama -f -n __fish_ollama_no_subcommand -a run -d 'Run a model'
complete -c ollama -f -n __fish_ollama_no_subcommand -a stop -d 'Stop a running model'
complete -c ollama -f -n __fish_ollama_no_subcommand -a pull -d 'Pull a model from a registry'
complete -c ollama -f -n __fish_ollama_no_subcommand -a push -d 'Push a model to a registry'
complete -c ollama -f -n __fish_ollama_no_subcommand -a list -d 'List models'
complete -c ollama -f -n __fish_ollama_no_subcommand -a ps -d 'List running models'
complete -c ollama -f -n __fish_ollama_no_subcommand -a cp -d 'Copy a model'
complete -c ollama -f -n __fish_ollama_no_subcommand -a rm -d 'Remove a model'
complete -c ollama -f -n __fish_ollama_no_subcommand -a help -d 'Help about any command'

# Global flags
complete -c ollama -f -n __fish_ollama_no_subcommand -s h -l help -d 'Help for ollama'
complete -c ollama -f -n __fish_ollama_no_subcommand -s v -l version -d 'Show version information'

# Help flag for all subcommands
complete -c ollama -f -n 'not __fish_ollama_no_subcommand' -s h -l help -d 'Help for subcommand'

# Model name completion function
function __fish_ollama_models
    # Get the output of ollama list and process it
    # Skip the header line and extract just the model names (first column)
    if command -sq ollama
        command ollama list 2>/dev/null | tail -n +2 | while read -l name size mod
            # Extract just the model name and add it as a completion option
            echo $name
        end
    end
end

# Subcommand argument completion
complete -c ollama -f -n '__fish_seen_subcommand_from show run stop cp rm' -a '(__fish_ollama_models)' -d Model
complete -c ollama -f -n '__fish_seen_subcommand_from push pull' -a '(__fish_ollama_models)' -d 'Model name'

# Special handling for create command
complete -c ollama -f -n '__fish_seen_subcommand_from create' -r -d 'Modelfile or model name'
