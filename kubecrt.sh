#!/bin/sh

while read -p "Please enter the name of the key and cert (should be same): " name
do
if [[ -z "$name" ]];
then
	echo "Please Enter the Name.... it's empty"
        sleep 1
elif [[ "$name" == "q"  ]] || [[ "$name" == "Q"  ]];
then
echo -ne 'exiting..\r'
sleep 0.2
echo -ne 'exiting...\r'
sleep 0.2
echo -ne 'exiting.....\r'
sleep 0.3
echo -ne 'exiting........\r'
sleep 0.3
break

else
	echo "Generating Certs...."
 
        echo -ne '#####                     (33%)\r'
        sleep 0.2
        echo -ne '########                  (45%)\r'
        sleep 0.3
        echo -ne '#############             (65%)\r'
        sleep 0.4
        echo -ne '##################        (88%)\r'
        sleep 0.4
        echo -ne '#######################   (100%)\r'
        echo -ne '\n'


	openssl genrsa -out $name.key 4096
	openssl req -new -key $name.key -out $name.csr -subj "/CN=$name/O=system:authenticated"

	reqval=$(cat $name.csr | base64 | tr -d "\n")

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $name
spec:
  groups:
  - system:authenticated
  request: $reqval
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

kubectl get csr 
kubectl certificate approve $name 
kubectl get csr $name -o jsonpath={.status.certificate} | base64 -d > $name.crt 

fi
break
done
