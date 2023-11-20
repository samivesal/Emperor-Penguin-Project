#! /bin/bash

# Author: sami pourvesal
# Created: September 23 2023
# Last Modified: September 23 2023


trap '_rollbackAllConfigurationsSIGINT' INT

_execute_command() {
    local command="$@"
    local log_file="$(pwd)/error.log"

    # Run the command and capture the output and errors
    output=$(eval "$command" 2>&1)

    # Check the exit status of the command
    exit_status=$?
    if [[ $exit_status -ne 0 ]]; then
        echo "$(date +'%Y-%m-%d %H:%M:%S') [ERROR] Command: $command" >> "$log_file" 2>/dev/null
        echo "$(date +'%Y-%m-%d %H:%M:%S') [ERROR] Error: $output" >> "$log_file" 2>/dev/null
        return ${exit_status}
    else
        echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] Command: $command" >> "$log_file" 2>/dev/null
        echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] Output: $output" >> "$log_file" 2>/dev/null
        return ${exit_status}
    fi
}


function _makeBackupFolder() {
    mkdir $(pwd)/Backup
}

function _deleteErrorLog() {
    sudo rm error.log >/dev/null 2>&1
}


function _backupFile() {
    sudo cp $1 $(pwd)/Backup
}

function _makeErrorLog(){
    sudo rm error.log >/dev/null 2>&1
    sudo touch error.log
    echo "Error happend while running script :" > error.log
}

function _makeLogTitle(){
    echo "" >> error.log
    echo "#-----------------------$1--------------------------------#" >> error.log
    echo "" >> error.log
}

function _backToDefaultColor (){
    tput sgr0
}


function _cloningImgProxy(){

    echo ""
    echo "Cloning imgproxy ..."
    echo "After this operation, imgproxy code will be cloned from its repository in github to /opt/project/ ."
    _makeLogTitle "Cloning imgproxy"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        if ! command -v git &> /dev/null; then
            echo "Git is not installed on your system. To continue running this script, you should install Git on your system."
            read -p "Do you want to install it? [Y/n] " response
            response=${response,,}

            # If the user wants to install git, install it
            if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
	    
                _execute_command 'sudo apt-get -y install git'

                # Check if git was successfully installed
                if [ $? -eq 0 ]; then
                    echo -e "${green}Git installing done successfully!"
                    _backToDefaultColor
                else
                    echo -e "${red}Failed to install Git. You can see in error.log why installing failed."
                    _backToDefaultColor
                    exit 1
                fi
            fi
        fi

        _execute_command 'git clone https://github.com/imgproxy/imgproxy.git /opt/project'

        
        if [ $? -eq 0 ]; then
            echo -e "${green}Cloning imgproxy to /opt/project done successfully"
            _backToDefaultColor
        else
            echo -e "${red}Failed to cloning from Git. You can see in error.log why cloning failed."
            _backToDefaultColor
            _rollBackCloningImgProxy
        fi
    
    else
        echo "Skipping from this step is not allowed."
        echo "You should have imgproxy to continue running script."
        exit 1
    fi
}
function _rollBackCloningImgProxy(){
    
    echo ""
    echo "Roll back cloning imgproxy ..."
    echo "After this operation, imgproxy code will be removed from its directory in your system."
    _makeLogTitle "Rollback cloning imgproxy"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        _execute_command 'sudo rm -r /opt/project'

        
        if [ $? -eq 0 ]; then
            echo -e "${green}Rollback cloning imgproxy to done successfully"
            _backToDefaultColor
            _cloningImgProxy
        else
            echo -e "${red}Failed to rollback cloning imgproxy. You can see in error.log why rollback failed."
            _backToDefaultColor
            exit 1
        fi
    
    else
        echo "Skipping from cloning rollback . . . "
    fi 
}

function _setLibvipsSources () {
	echo "deb http://deb.debian.org/debian bullseye main contrib non-free" >> /etc/apt/sources.list
 	echo "deb-src http://deb.debian.org/debian bullseye main contrib non-free" >> /etc/apt/sources.list
	echo "deb http://security.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list
    echo "deb-src http://security.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list
	echo "deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list
 	echo "deb-src http://deb.debian.org/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list
	_execute_command 'sudo apt-get clean'
 	_execute_command 'sudo apt-get update'
}

function _installLibVips(){
    
    echo ""
    echo "Installing imgproxy's dependency ..."
    echo "After this operation, libvips will be installed on your device ."
    _makeLogTitle "Install Libvips"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        if ! command -v libvips &> /dev/null; then
            _execute_command 'sudo apt-get -y install libvips-dev'
        else
            echo 'libvips is already installed.'
        fi

        
        if [ $? -eq 0 ]; then
            echo -e "${green}Installing Libvips done successfully"
            _backToDefaultColor
        else
            echo -e "${red}Failed to installing Libvips. You can see in error.log why installing failed."
            _backToDefaultColor
            _rollBackInstallingLibVips
        fi
    
    else
        echo "Skipping installing Libvips ..."
    fi
}

function _rollBackInstallingLibVips(){
    
    echo ""
    echo "Roll back installing imgproxy's dependency..."
    echo "After this operation, Libvips code will be removed from its directory in your system."
    _makeLogTitle "Rollback installing Libvips"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        _execute_command 'sudo apt purge libvips-dev'

        
        if [ $? -eq 0 ]; then
            echo -e "${green}Rollback installing imgproxy's dependency done successfully ."
            _backToDefaultColor
            _installLibVips
        else
            echo -e "${red}Failed to rollback cloning imgproxy. You can see in error.log why rollback failed."
            _backToDefaultColor
            exit 1
        fi
    
    else
        echo "Skipping from installing imgproxy's dependency rollback . . . "
    fi 
}

function _installGolangCompiler(){
    
    echo ""
    echo "Installing Golang compiler ..."
    echo "After this operation, Golang will be installed on your device ."
    _makeLogTitle "Install Golang"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        if ! command -v go &> /dev/null; then
            _execute_command 'sudo rm -rf /usr/local/go'
            #_execute_command 'wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz'
            _execute_command 'sudo tar -xvf go1.21.3.linux-amd64.tar.gz'
            _execute_command 'sudo mv go /usr/local'
        else
            echo 'Golang is already installed.'
        fi

        
        if [ $? -eq 0 ]; then
            echo -e "${green}Installing Golang done successfully"
            _backToDefaultColor
            sleep 2
        else
            echo -e "${red}Failed to installing Golang. You can see in error.log why installing failed."
            _backToDefaultColor
            _rollBackInstallingGolang
        fi
    
    else
        echo "Skipping installing Golang ..."
        sleep 2
    fi
}

function _rollBackInstallingGolang(){

    echo ""
    echo "Roll back installing Golang ..."
    echo "After this operation, Golang will be removed from your system."
    _makeLogTitle "Rollback installing Golang"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        _execute_command 'sudo rm -rf /usr/local/go'

        
        if [ $? -eq 0 ]; then
            echo -e "${green}Rollback installing Golang done successfully ."
            _backToDefaultColor
            _installGolangCompiler
        else
            echo -e "${red}Failed to rollback installing Golang. You can see in error.log why rollback failed."
            _backToDefaultColor
            exit 1
        fi
    
    else
        echo "Skipping from installing Golang rollback . . . "
    fi 
}

function _set403DNS () {
    sudo bash -c 'cat << EOF > /etc/resolv.conf
nameserver 10.202.10.202
nameserver 10.202.10.102
EOF'
}


function _runningImgProxy() {

    echo ""
    echo "Running imgproxy ..."
    echo "After this operation, imgproxy will be installed on your device ."
    _makeLogTitle "Running imgproxy"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        cd /opt/project
	    sudo CGO_LDFLAGS_ALLOW="-s|-w" /usr/local/go/bin/go build -buildvcs=false -o /usr/local/bin/imgproxy
        
        if [ -f /usr/local/bin/imgproxy ] && [ $? -eq 0 ]; then
            echo -e "${green}Running imgproxy done successfully ."
            cd - > /dev/null 2>&1
            _backToDefaultColor
        else
            echo -e "${red}Failed to rollback running imgproxy. You can see in error.log why rollback failed."
            cd - > /dev/null 2>&1
            _backToDefaultColor
            _rollbackRunningImgProxy
        fi
    
    else
        echo "Skipping installing Golang ..."
        sleep 2
    fi
}

function _rollbackRunningImgProxy() {
    echo ""
    echo "Rollback running imgproxy ..."
    echo "After this operation, imgproxy will be removed from your device ."
    _makeLogTitle "Rollback running imgproxy"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        _execute_command 'sudo rm /usr/local/bin/imgproxy'
        
        if [ -f /usr/local/bin/imgproxy ] ; then
            echo -e "${green}Rollback running imgproxy done successfully ."
            _backToDefaultColor
            _runningImgProxy
        else
            echo -e "${red}Failed to rollback running imgproxy. You can see in error.log why rollback failed."
            _backToDefaultColor
            exit 1
        fi
    
    else
        echo "Skipping running imgproxy rollback ..."
        sleep 2
    fi
}

function _set403DNS () {
    sudo bash -c 'cat << EOF > /etc/resolv.conf
nameserver 8.8.8.8
EOF'
}

function _setImgProxyUnitFile () {

    echo ""
    echo "Creating and setting imgproxy unit file ..."
    echo "After this operation, imgproxy unit file will be created and set on your device ."
    _makeLogTitle "Creating and setting imgproxy unit file"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        _execute_command 'wget --no-check-certificate https://raw.githubusercontent.com/SalehGovahi/EmperorPenguinProject/Phase1/ConfigSettings/imgproxyservice.txt'
        imgproxy_file="$(pwd)/imgproxyservice.txt"

        if [ -f $imgproxy_file ] ; then
            
            _execute_command 'sudo rm /etc/systemd/system/imgproxy.service'
            _execute_command 'sudo mv $imgproxy_file /etc/systemd/system/imgproxy.service'

            
            if [ -f /etc/systemd/system/imgproxy.service ] ; then
                
                echo -e "${green}Creating unit file done successfully."
                
                echo "Prepaing imgproxy service ..."
                
                _execute_command 'sudo systemctl daemon-reload'
                _execute_command 'sudo systemctl enable imgproxy.service'
                _execute_command 'sudo systemctl start imgproxy.service'


                if systemctl is-enabled imgproxy && systemctl is-active imgproxy; then
                    echo -e "${green}Imgproxy service is enabled and activated."
                    _backToDefaultColor
                else
                    echo -e "${red}Imgproxy service is not enabled and activated. You can see in error.log why service preparation failed."
                    _backToDefaultColor
                    _rollBackSetImgProxyUnitFile
                fi
                
            else
                echo -e "${red}Failed to create imgproxy.service file. You can see in error.log why move failed."
                _backToDefaultColor
                _rollBackSetImgProxyUnitFile
            fi
        else
            echo -e "${red}Failed to download imgproxyservice.txt file. You can see in error.log why download failed."
            _backToDefaultColor
            _rollBackSetImgProxyUnitFile
        fi
    
    else
        echo "Skipping setting imgproxy unit file ..."
        sleep 2
    fi

}

function _rollBackSetImgProxyUnitFile () {
    
    echo ""
    echo "Rollback setting imgproxy unit file..."
    echo "After this operation, imgproxy unit will be removed from your device and imgproxy service will be stopped."
    _makeLogTitle "Rollback running imgproxy"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        _execute_command 'sudo rm /etc/systemd/system/imgproxy.service'
        
        _execute_command 'sudo systemctl stop imgproxy.service'
        _execute_command 'sudo systemctl daemon-reload'

        if [ $? -eq 0 ]; then
            echo -e "${green}Rollback Setting imgproxy unit file done successfully ."
            _backToDefaultColor
            _setImgProxyUnitFile
        else
            echo -e "${red}Failed to rollback setting imgproxy unit file. You can see in error.log why rollback failed."
            _backToDefaultColor
            exit 1
        fi
        
    else
        echo "Skipping running imgproxy rollback ..."
        sleep 2
    fi     
}

function _checkHealthImgproxy () {
    
    echo ""
    echo "Imgproxy healthcheck ..."
    echo "After this operation, imgproxy will be checked that it runs healthily or not."
    _makeLogTitle "Imgproxy Healthcheck"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        url=http://localhost:8080/health
        x=$(curl -sI $url | grep HTTP | awk '{print $2}')
        
        if [ -z "$x" ]; then
            echo -e "${red}Imgproxy is running not healthily."
            _backToDefaultColor
            sleep 2
        else
            if [ "$x" -eq 200 ]; then
                echo -e "${green}Imgproxy is running healthily."
                _backToDefaultColor
                sleep 2
            else
                echo -e "${red}Imgproxy is running not healthily."
                _backToDefaultColor
                sleep 2
            fi
        fi
    
    else
        echo "Skipping checking imgproxy ..."
        sleep 2
    fi
}

function _accessiblePort8080 () {

    echo ""
    echo "Configuring network ..."
    echo "After this operation, port of imgproxy will be accessible from outside of device."
    _makeLogTitle "Configuring network"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then

        #_execute_command 'sudo apt-get -y purge nftables'
	_execute_command 'sudo systemctl disable nftables'
        _execute_command 'sudo systemctl stop nftables'
        _execute_command 'sudo systemctl enable nftables'
        _execute_command 'sudo systemctl start nftables'
        # _execute_command 'sleep 5'
        _execute_command 'sudo nft add rule inet filter input tcp dport 8080 accept'
        _execute_command 'sudo nft list ruleset > /etc/nftables.conf'
        _execute_command 'sudo nft -f /etc/nftables.conf'
        _execute_command 'sudo systemctl restart nftables'
        
        if [ $? -eq 0 ]; then
            echo -e "${green}Configuring network done successfully"
            _backToDefaultColor
        else
            echo -e "${red}Failed to configuring network. You can see in error.log why configuring failed."
            _rollBackAccessiblePort8080
            _backToDefaultColor
        fi
    
    else
        echo "Skipping configuring network ..."
    fi

}

function _rollBackAccessiblePort8080 () {
    
    echo ""
    echo "Rollback configuring network ..."
    echo "After this operation, your network configuration will be removed and network configuration will be set to default."
    _makeLogTitle "Rollback configuring network ..."

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        echo "Removing nftables rules ..."

        _execute_command 'sudo systemctl restart nftables'
        _execute_command 'sudo nft delete rule inet filter input handle 4'
        _execute_command 'sudo nft list ruleset > /etc/nftables.conf'
        _execute_command 'sudo nft -f /etc/nftables.conf'

        if [ $? -eq 0 ]; then
            echo -e "${green}Rollback configuring network done successfully ."
            _backToDefaultColor
            _accessiblePort8080
        else
            echo -e "${red}Failed to rollback configuring network. You can see in error.log why rollback failed."
            _backToDefaultColor
            exit 1
        fi
        
    else
        echo "Skipping network configuring rollback ..."
        sleep 2
    fi  

}


function _rollbackAllConfigurations() {
    echo ""
    echo "Rolling back all configurations..."
    echo "After this operation, all configurations will be rolled back."
    _makeLogTitle "Rollback All Configurations"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        _execute_command 'sudo rm -r /opt/project'

        _execute_command 'sudo apt-get -y purge libvips-dev'

        _execute_command 'sudo apt-get -y purge golang'
        
        _execute_command 'sudo apt-get -y autoremove'

        _execute_command 'sudo rm /usr/local/bin/imgproxy'

        _execute_command 'sudo rm /etc/systemd/system/imgproxy.service'
        
        _execute_command 'sudo systemctl stop imgproxy.service'
        
        _execute_command 'sudo systemctl daemon-reload'

        _execute_command 'sudo systemctl restart nftables'
        
        _execute_command 'sudo nft delete rule inet filter input handle 4'
        
        _execute_command 'sudo nft list ruleset > /etc/nftables.conf'
        
        _execute_command 'sudo nft -f /etc/nftables.conf'

        echo -e "${green}Rollback all configurations done successfully."
        _backToDefaultColor

    else
        echo "Skipping rollback all configurations..."
    fi
}

function _rollbackAllConfigurationsSIGINT() {

    clear
    echo "You sent interrupt signal to proccess"
    echo "Rolling back all configurations..."
    _makeLogTitle "Rollback All Configurations SIGINT"

    _execute_command 'sudo rm -r /opt/project'

    _execute_command 'sudo apt-get -y purge libvips-dev'

    _execute_command 'sudo apt-get -y purge golang'
        
    _execute_command 'sudo apt-get -y autoremove'

    _execute_command 'sudo rm /usr/local/bin/imgproxy'

    _execute_command 'sudo rm /etc/systemd/system/imgproxy.service'
        
    _execute_command 'sudo systemctl stop imgproxy.service'
        
    _execute_command 'sudo systemctl daemon-reload'

    _execute_command 'sudo systemctl restart nftables'
        
    _execute_command 'sudo nft delete rule inet filter input handle 4'
        
    _execute_command 'sudo nft list ruleset > /etc/nftables.conf'
        
    _execute_command 'sudo nft -f /etc/nftables.conf'

    sleep 2
    exit 1 

}


. "bash-menu.sh"

actionA() {
    echo "Running Script ..."
    _deleteErrorLog
    _cloningImgProxy
	_setLibvipsSources
    _installLibVips
    _set403DNS
    _installGolangCompiler
    _runningImgProxy
    _setImgProxyUnitFile
    _checkHealthImgproxy
    _accessiblePort8080
    sleep 10
    return 1
}

actionB() {
    echo "Roll Back all configurations ..."
    _rollbackAllConfigurations
    return 1
}

actionC() {
    clear
    url="https://github.com/SalehGovahi/EmperorPenguinProject/wiki"
    link_text="See project's wiki"

    sudo echo -e "To visit the website, \e]8;;$url\e\\$link_text\e]8;;\e\\"

    sleep 10
    return 0
}


actionX() {
    return 0
}


menuItems=(
    "1. Running Script"
    "2. RollBack All Configurations"
    "3. About Script"
    "4. Exit  "
)

## Menu Item Actions
menuActions=(
    actionA
    actionB
    actionC
    actionX
)


menuTitle=" Demo of bash-menu"
menuFooter=" Enter=Select, Navigate via Up/Down/First number/letter"
menuWidth=60
menuLeft=25
menuHighlight=$DRAW_COL_YELLOW


if [[ $EUID -eq 0 ]]; then

    ping -c 1 8.8.8.8 >/dev/null 2>&1

    if [[ $? -eq 0 ]]; then
        menuInit
        menuLoop          
    else
        echo "You should connect to the internet to run this script. Try again later."
    fi
else
    echo "This script must be run as root."
    exit 1
fi