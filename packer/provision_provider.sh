provider=$1

function usage() {
  echo "USAGE: ${0} <aws||docker||virtualbox||vmware>"
  exit 1
}

if [[ $# != 1 ]]; then
  usage
fi

echo "Provisioning ${provider}..."
case $provider in
  'aws')
    ./provisioners/pack_aws.sh
    ;;
  'docker')
    ./provisioners/pack_docker.sh
    ;;
  'virtualbox')
    ./provisioners/pack_virtualbox.sh
    ;;
  'vmware')
    ./provisioners/pack_vmware.sh
    ;;
  *)
    usage
    ;;
esac
