#!/bin/zsh

name="lambda_dotnetcore2.1"
working=$(pwd)
config="Debug"
publish="pub"
me=$(hostname | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')

# Clean up any existing build objects
rm -rf bin
rm -rf obj
rm -rf $publish

# Build the dotnet app (test.dll) and output to the pub folder
echo "> Building test.csproj in container"
docker run --rm -v "${working}:/var/task" lambci/lambda:build-dotnetcore2.1 dotnet publish -c $config -o $publish

# Build our lambda container with VSDBG installed based on lambci/lambda:dotnetcore2.1
echo "> Building lambda dotnetcore2.1 container"
docker build -q -t "${me}/lambda:dotnetcore2.1" .

# Kill running container if it exists
id=$(docker ps --filter "name=${name}" --format "{{.ID}}")
if [[ $id ]]; then
  echo "> Cleaning up existing lambda dotnetcore2.1 container"
  docker kill $id
fi

# Start our custom lambda container as a detached process
# Note: The container will start and wait until a debugger is attached
echo "> Running lambda dotnetcore2.1 container"
docker run --name $name -d --rm -v "${working}/${publish}:/var/task" "${me}/lambda:dotnetcore2.1"

# Clean up docker build objects
rm -rf bin
rm -rf obj

# Build locally for syntax highlighting
echo "> Building test.csproj locally"
dotnet build -c Debug -v quiet

echo "> Run the vscode debugger to continue"
