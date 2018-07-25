$name = "lambda_dotnetcore2.1"
$working = Get-Location
$config = "Debug"
$publish = "pub"
$me = ($env:ComputerName).toLower()

# Clean up any existing build objects
Remove-Item bin -Recurse -Force -ErrorAction Ignore
Remove-Item obj -Recurse -Force -ErrorAction Ignore
Remove-Item $publish -Recurse -Force -ErrorAction Ignore

# Build the dotnet app (test.dll) and output to the pub folder
Write-Host "> Building test.csproj in container"
docker run --rm -v "${working}:/var/task" lambci/lambda:build-dotnetcore2.1 dotnet publish -c $config -o $publish

# Build our lambda container with VSDBG installed based on lambci/lambda:dotnetcore2.1
Write-Host "> Building lambda dotnetcore2.1 container"
docker build -q -t "$me/lambda:dotnetcore2.1" .

# Kill running container if it exists
$id = docker ps --filter "name=$name" --format "{{.ID}}"
if ($id) {
  Write-Host "> Cleaning up existing lambda dotnetcore2.1 container"
  docker kill $id
}

# Start our custom lambda container as a detached process
# Note: The container will start and wait until a debugger is attached
Write-Host "> Running lambda dotnetcore2.1 container"
docker run --name $name -d --rm -v "${working}\${publish}:/var/task" "$me/lambda:dotnetcore2.1"

# Clean up docker build objects
Remove-Item bin -Recurse -Force -ErrorAction Ignore
Remove-Item obj -Recurse -Force -ErrorAction Ignore

# Build locally for syntax highlighting
Write-Host "> Building test.csproj locally"
dotnet build -c Debug -v quiet

Write-Host "> Run the vscode debugger to continue"
