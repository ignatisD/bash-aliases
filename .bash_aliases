alias untar="tar -zxvf"
alias targz="tar cvzf"
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
function btc()
{
    local OPTIND
    usage() { echo "Usage: btc [-c USD] [-t <int>]" 1>&2; exit 1; }
	PAIR=EUR
	COINPAIR="BTC-EUR"
	KRAKPAIRRES="XXBTZEUR"
	KRAKPAIR="XBTEUR"
    SLEEP_FOR=""
    while getopts ":t::c::" o; do
        case "${o}" in
            t)
                SLEEP_FOR=${OPTARG}
                ;;
            c)
				if [[ ! -z ${OPTARG} ]]; then
                	PAIR="${OPTARG:0:3}";
                	PAIR="${PAIR^^}";
                	if [[ $PAIR = "USD" ]]; then
                	    KRAKPAIR="XBTUSD"
	                    KRAKPAIRRES="XXBTZUSD"
	                    COINPAIR="BTC-USD"
                    else
                	    KRAKPAIR="${PAIR}XBT"
	                    KRAKPAIRRES="X${PAIR}XXBT"
	                    COINPAIR="${PAIR}-BTC"
                	fi;
				fi;
                ;;
            *)
                usage
                return;
                ;;
        esac
    done
    shift $(( OPTIND - 1 ))
    while true; do
        echo "-------------------------------------------------"
        KRAKNODE="parseFloat(JSON.parse(require('fs').readFileSync('/dev/stdin').toString()).result.${KRAKPAIRRES}.c[0])"
        COINNODE="parseFloat(JSON.parse(require('fs').readFileSync('/dev/stdin').toString()).price)"
        KRAKENTO=""
        COINBASETO=""
        KRAKEN=$(curl -s -k -X GET "https://api.kraken.com/0/public/Ticker?pair=${KRAKPAIR}" | node -pe "${KRAKNODE}")
        COINBASE=$(curl -s -k -X GET "https://api.pro.coinbase.com/products/${COINPAIR}/ticker" | node -pe "${COINNODE}")

            KRAK=$(node -pe "((parseFloat(${KRAKEN}) - parseFloat('${PREVKRAKEN}' || ${KRAKEN}))*100/parseFloat(${KRAKEN})).toFixed(2)")
            COIN=$(node -pe "((parseFloat(${COINBASE}) - parseFloat('${PREVCOINBASE}' || ${COINBASE}))*100/parseFloat(${COINBASE})).toFixed(2)")
            if [[ "${PREVKRAKEN}" > "${KRAKEN}" ]]; then
                KRAKENTO="\033[31m${KRAK}%"
            else
                KRAKENTO="\033[32m+${KRAK}%"
            fi;
            if [[ "${PREVCOINBASE}" > "${COINBASE}" ]]; then
                COINBASETO="\033[31m${COIN}%"
            else
                COINBASETO="\033[32m+${COIN}%"
            fi;
        echo -e "- \033[94mCoinbase : 1 BTC = ${COINBASE} ${PAIR} ${COINBASETO}\033[0m \t"
        echo -e "- \033[95mKraken   : 1 BTC = ${KRAKEN} ${PAIR} ${KRAKENTO}\033[0m \t"
        echo "-------------------------------------------------"
        if [[ -z "${PREVKRAKEN}" ]]; then
            PREVKRAKEN=${KRAKEN}
            PREVCOINBASE=${COINBASE}
        fi;
        if [ -z "${SLEEP_FOR}" ]; then
            return;
        fi;
        sleep "${SLEEP_FOR}"
        echo -e "\033[5A"
    done;
}
