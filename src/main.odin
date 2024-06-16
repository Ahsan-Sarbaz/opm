package main

import "core:fmt"
import "core:io"
import "core:os"
import "core:strings"

is_verbose := false
main_odin_src := `package main

import "core:fmt"

main :: proc() {
    fmt.println("Hello, World!")
}
`

ols_json_src := `{
    "$schema": "https://raw.githubusercontent.com/DanielGavin/ols/master/misc/ols.schema.json",
    "enable_semantic_tokens": true,
    "enable_document_symbols": true,
    "enable_hover": true,
    "enable_snippets": true,
    "enable_format": true
}`


olsfmt_json_src := `{
    "$schema": "https://raw.githubusercontent.com/DanielGavin/ols/master/misc/odinfmt.schema.json",
    "character_width": 120,
    "tabs": false,
    "spaces": 4
}`

launch_json_src := `{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "cppvsdbg",
            "request": "launch",
            "name": "Debug",
            "program": "${workspaceFolder}/build/${workspaceFolderBasename}.exe",
            "args": [],
            "cwd": "${workspaceFolder}",
            "preLaunchTask": "Build"
        }
    ]
}`


tasks_json_src := `{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build",
            "type": "shell",
            "command": "odin build src -out:build/${workspaceFolderBasename}.exe -debug",
            "group": {
                "kind": "build",
                "isDefault": true
            }
        }
    ]
}`

create_dir :: proc(path: string) -> bool {
	if os.exists(path) {
		return false
	}

	if os.make_directory(path) != os.ERROR_NONE {
		fmt.printfln("Failed to create directory: %s", path)
		return false
	}

    if is_verbose {
        fmt.printfln("Created directory: %s", path)
    }

	return true
}

create_required_directories :: proc(project_dir: string) -> bool {
    
	return (
        create_dir(project_dir)
	    && create_dir(strings.concatenate({project_dir, "/build"}))
	    && create_dir(strings.concatenate({project_dir, "/.vscode"}))
	    && create_dir(strings.concatenate({project_dir, "/src"}))
    )
}

create_file_and_write :: proc(path: string, content: string) -> bool {

	f, err := os.open(path, os.O_WRONLY | os.O_CREATE)
	defer os.close(f)

	if err != os.ERROR_NONE {
		fmt.printfln("Failed to create file: %s", path)
		return false
	}

	_, err = os.write_string(f, content)
	if err != os.ERROR_NONE {
		fmt.printfln("Failed to create file: %s", path)
		return false
	}

    if is_verbose {
    	fmt.printfln("Created file: %s", path)
    }

	return true
}

create_required_files :: proc(project_dir: string) -> bool {
	return (
        create_file_and_write(strings.concatenate({project_dir, "/ols.json"}), ols_json_src)
        && create_file_and_write(strings.concatenate({project_dir, "/olsfmt.json"}), olsfmt_json_src)
        && create_file_and_write(strings.concatenate({project_dir, "/.vscode/launch.json"}), launch_json_src)
        && create_file_and_write(strings.concatenate({project_dir, "/.vscode/tasks.json"}), tasks_json_src)
        && create_file_and_write(strings.concatenate({project_dir, "/src/main.odin"}), main_odin_src)
    )
}

help_string := `
Usage: opm <dir>
Create a new project in the given directory.
Options: --verbose
         --help
         --version
Example: opm game
Example: opm --verbose game
Example: opm --help
`

main :: proc() {

	if (len(os.args) == 1) {
		fmt.println(help_string)
		return
	}

    project_dir : string = " "

    for arg, index in os.args[1:] {
        if strings.has_prefix(arg, "--")  {
            if arg == "--version" {
                
            } else if arg == "--help" {
                fmt.println(help_string)
                return
            } else if arg == "--verbose" {
                is_verbose = true
            } else {
                fmt.println("Unknown option: ", arg)
            }
        }
        else
        {
            project_dir = arg
        }
    }

    if project_dir == "" || project_dir == " " {
        fmt.println("Missing project directory")
        return
    }
    
	if !create_required_directories(project_dir) || !create_required_files(project_dir) {
		return
	}

    if is_verbose {
        fmt.println("Created project in: ", project_dir)
        fmt.println("You can now use VSCode to build and debug your project.")
    }
}
