# ===========================================
# Intune-ready Kyocera Printer Deployment Script
# Works on clean machines
# ===========================================

# Variables
$DriverPath   = "$PSScriptRoot\KyoceraDriver"      # Path to your driver folder
$DriverInf    = "oemsetup.inf"                     # INF file name from the driver package
$DriverName   = "Kyocera TASKalfa 2553ci KX"      # EXACT driver name from INF / Get-PrinterDriver
$PrinterName  = "Inter"                            # Desired printer name
$PortName     = "inter"                            # Port name
$PrinterIP    = "172.16.137.128"                  # Printer IP
$LprQueueName = "inter"                            # LPR queue name

# Logging
$LogFile = "C:\ProgramData\PrinterDeploy.log"

function Write-Log {
    param([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$TimeStamp - $Message" | Out-File -FilePath $LogFile -Append -Force
    Write-Host $Message
}

Write-Log "========== Kyocera Printer Deployment Started =========="

# Install printer driver if missing
function InstallDriver {
    try {
        if (-not (Get-PrinterDriver -Name $DriverName -ErrorAction SilentlyContinue)) {
            Write-Log "Installing printer driver $DriverName from INF..."
            Add-PrinterDriver -Name $DriverName -InfPath "$DriverPath\$DriverInf"
            Write-Log "Driver installed successfully."
        } else {
            Write-Log "Driver $DriverName already installed."
        }

        AddPort
    } catch {
        Write-Log "ERROR: Failed to install driver: $_"
        exit 1
    }
}

# Create LPR port if missing
function AddPort {
    try {
        if (-not (Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue)) {
            Write-Log "Creating LPR port $PortName..."
            # FIXED: Removed invalid -Lpr parameter
            Add-PrinterPort -Name $PortName -LprHostAddress $PrinterIP -LprQueueName $LprQueueName -LprByteCounting
            Write-Log "Port created successfully."
        } else {
            Write-Log "Port $PortName already exists."
        }

        AddPrinter
    } catch {
        Write-Log "ERROR: Failed to create printer port: $_"
        exit 1
    }
}

# Add printer if missing
function AddPrinter {
    try {
        if (-not (Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue)) {
            Write-Log "Adding printer $PrinterName..."
            Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $PortName
            Write-Log "Printer added successfully."
        } else {
            Write-Log "Printer $PrinterName already exists."
        }
    } catch {
        Write-Log "ERROR: Failed to add printer: $_"
        exit 1
    }
}

# Initiate script
InstallDriver

Write-Log "========== Kyocera Printer Deployment Completed Successfully =========="
exit 0
