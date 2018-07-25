# Info

This project was built to test dotnet core 2.0/2.1 debugging within the lambda dotnet runtime docker container.

## Setup & Run

1. `> docker pull lambci/lambda:build-dotnetcore2.1`
1. `> docker pull lambci/lambda:dotnetcore2.1`
1. `> .\run.ps1` on windows or `> chmod +x run.sh && ./run.sh` on linux/mac
1. Set a breakpoint in Function.cs
1. Run the vscode _.NET Core Docker Launch (console)_ launch task (F5)
1. Profit!

## Description

This project utilized the container images from the [lambci/docker-lambda](https://github.com/lambci/docker-lambda/tree/master/examples/dotnetcore2.1) project as well as the sample code and vscode launch configuration from the [sleemer/docker.dotnet.debug](https://github.com/sleemer/docker.dotnet.debug) project.

The __lambci/lambda:dotnetcore2.1__ container image was modified to include VSDBG, the dotnet core debugger. Furthermore, the entrypoint was changed to wait for a debugger to attach to the container.

The vscode launch configuration was modified to use the `pipeTransport` protocol to communicate with VSDBG in the docker container and run the lambda bootstrapper, __MockBootstraps.dll__.

Another option would be to have a second container with vsdbg installed in a volume. Then attach that volume as a read-only volume to the lambda container. Example:
```
version: "2"
volumes:
  vsdbg:
services:
  vsdbg:
    image: stephpr/vsdbg
    volumes:
    - vsdbg:/vsdbg
  my-mvc-app:
    depends_on:
    - vsdbg
    volumes:
    - vsdbg:/vsdbg:ro
```

## Screenshots

![Debugging Lambda](img/debugging_docker.png "Debugging Lambda")

## launch.json

```
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": ".NET Core Docker Launch (console)",
            "type": "coreclr",
            "request": "launch",
            "program": "/var/runtime/MockBootstraps.dll",
            "args": [
                "test::test.Function::FunctionHandler",
                "{\"foo\":\"bar\"}"
            ],
            "cwd": "/var/task",
            "sourceFileMap": {
                "/var/task": "${workspaceRoot}"
            },
            "logging": {
                "engineLogging": true,
                "exceptions": true,
                "moduleLoad": true,
                "programOutput": true
            },
            "pipeTransport": {
                "pipeProgram": "docker",
                "pipeCwd": "${workspaceRoot}",
                "pipeArgs": [
                    "exec",
                    "-i",
                    "lambda_dotnetcore2.1"
                ],
                "quoteArgs": false,
                "debuggerPath": "/vsdbg/vsdbg"
            },
            "justMyCode": true
        },
        // https://github.com/aspnet/AspLabs/blob/b45cc521b2b38b024cb5e202c4cece166eb6f915/src/MultiStageBuild/MyMvcApp/.vscode/launch.json
        {
            "name": "ASP .NET Core Launch (Docker)",
            "type": "coreclr",
            "request": "launch",
            "preLaunchTask": "docker-build",
            "pipeTransport": {
                "pipeProgram": "docker",
                "pipeCwd": "${workspaceRoot}",
                "pipeArgs": [
                    "run",
                    "-v",
                    "${workspaceRoot}/.vscode/docker/vsdbg:/vsdbg",
                    "-v",
                    "${workspaceRoot}:/.src",
                    "-p",
                    "5000:80",
                    "--entrypoint",
                    "/bin/sh",
                    "-i",
                    "--rm",
                    "my-mvc-app:develop",
                    "/.src/.vscode/docker/run.sh"
                ],
                "quoteArgs": false,
                "debuggerPath": "/vsdbg/vsdbg"
            }
        }
    ]
}
```
