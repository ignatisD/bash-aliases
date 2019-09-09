alias untar="tar -zxvf"
alias clipfile="xclip -sel clip"
alias clipout="xclip -o -sel clip"
alias myip=GetMyIP
alias myinter=GetMyInterface
alias postmanupdate=UpdatePostman
alias gitstats="git diff --shortstat"
alias memoryusage=memoryUsage
alias remoteupload=RemoteUpload
alias remotedownload=RemoteDownload
alias tsnpm=InstallNpmWithTypes
alias match=PerlMatch
alias aliasedit=EditMyAliases
alias sshedit="gedit ~/.ssh/config"
alias btc=GetBTCPrice


function EditMyAliases() 
{
	if [ "$1" != "" ] && [ -f ~/.bash_"$1" ]; then
		gedit ~/.bash_"$1"
		return;
	fi;
	if [ "$1" == "ssh" ]; then
		gedit ~/.ssh/config
		return;
	fi;
	gedit ~/.bash_aliases
}

function PerlMatch()
{
	grep -oP "$1"
}

function InstallNpmWithTypes()
{
	npm i --save "$1" && npm i --save-dev @types/"$1"
}


function RemoteDownload()
{
  scp "$1":"$2" "$3"
}

function RemoteUpload()
{
  scp -p "$1" "$2":"$3"
}

function memoryUsage()
{
	ps -eo size,pid,user,command --sort -size | awk '{ hr=$1/1024 ; printf("%13.2f Mb ",hr) } { for ( x=4 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }' |cut -d "" -f2 | cut -d "-" -f1
}

function UpdatePostman()
{
    wget https://dl.pstmn.io/download/latest/linux64 -O ~/Downloads/postman.tar.gz
    sudo tar -xzf ~/Downloads/postman.tar.gz -C /opt
    rm ~/Downloads/postman.tar.gz
}

function GetMyIP()
{
    echo Local: $(ip route get 8.8.8.8 | awk '{print $(NF-2); exit}')  
	if [ "$1" == "" ]; then 
    	echo Public: $(curl -s -w " - Ping: %{time_total} sec\n" http://whatismyip.akamai.com)   
	else   
		echo Public: $(curl -x "$1" -s -w " - Ping: %{time_total} sec\n" http://whatismyip.akamai.com)   
	fi;
}

function GetMyInterface()
{
   	TEST_HOST=google.com
	TEST_HOST_IP=$(getent ahosts "$TEST_HOST" | awk '{print $1; exit}')
	ACTUAL_INTERFACE=$(ip route get "$TEST_HOST_IP" | grep -Po '(?<=(dev )).*(?= src| proto)')
	echo -e "Interface: \e[38;5;196m${ACTUAL_INTERFACE:-NOT_FOUND}\e[0m"
}

function GetBTCPrice() 
{

	PAIR=EUR
	if [[ ${1} = USD ]] | [[ ${1} = usd ]]; then PAIR=USD; fi;

	KRAKEN=$(curl -s -k -X GET "https://api.kraken.com/0/public/Ticker?pair=XBT${PAIR}" | node -pe "parseFloat(JSON.parse(require('fs').readFileSync('/dev/stdin').toString()).result.XXBTZ${PAIR}.c[0]).toFixed(2)")
	COINBASE=$(curl -s -k -X GET "https://api.coinbase.com/v2/exchange-rates?currency=BTC" | node -pe "parseFloat(JSON.parse(require('fs').readFileSync('/dev/stdin').toString()).data.rates.${PAIR}).toFixed(2)")
	echo -e "\033[94mCoinbase : 1 BTC = ${COINBASE} ${PAIR} \033[0m"
	echo -e "\033[95mKraken   : 1 BTC = ${KRAKEN} ${PAIR} \033[0m"
}
