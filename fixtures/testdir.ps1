BeforeEach {
    if ([string]::IsNullOrWhiteSpace($TestDrive)) {
        throw "TestDrive not defined, refusing to continue"
    }

    Remove-Item TestDrive:/compressed, TestDrive:/extracted -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force TestDrive:/compressed, TestDrive:/extracted
}
