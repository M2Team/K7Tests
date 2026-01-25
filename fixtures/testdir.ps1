BeforeEach {
    if ([string]::IsNullOrWhiteSpace($TestDrive)) {
        throw "TestDrive not defined, refusing to continue"
    }

    $ScratchPaths = @(
        "TestDrive:/compressed",
        "TestDrive:/extracted",
        "TestDrive:/scratch"
    )
    Remove-Item $ScratchPaths -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force $ScratchPaths
}
