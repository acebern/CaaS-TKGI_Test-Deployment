pipeline {
	agent any
    
    environment {

        TKGI_ENDPOINT = "gtcstgvkstka001.globetel.com"
        HARBOR_ENDPOINT = "GTCSTGVKSTHR001.globetel.com"
        CLUSTER_ENDPOINT = "nonProdTestCluster.dif.globetel.com"
        MASTER_IP = "10.25.164.22"

    }

    stages {

        stage('Prepare') {
            steps {
                withCredentials([file(credentialsId: 'harbor-cert', variable: 'HARBOR_CERT')]) 
                {
                    sh '''
                        sudo mkdir -p /etc/docker/certs.d/$HARBOR_ENDPOINT
                        sudo cp $HARBOR_CERT /etc/docker/certs.d/$HARBOR_ENDPOINT/ca.crt

                    '''

                }
            }
        }  

        stage('Cluster Authentication and Image Push to Harbor') {
            steps {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'tkgiadmin', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) 
                {
                    sh '''

                        ls -al

                        sudo chmod +x tkgi-get-credentials.sh
                        sudo -- sh -c -e "echo $MASTER_IP $CLUSTER_ENDPOINT >> /etc/hosts"

                        sudo tkgi login -a $TKGI_ENDPOINT -u $USERNAME -k -p $PASSWORD
                        sudo tkgi clusters

                        sudo ./tkgi-get-credentials.sh $PASSWORD

                        sudo kubectl get nodes

                        sudo docker login -u tkgiadmin $HARBOR_ENDPOINT -p $PASSWORD
                        sudo docker tag nginx:latest $HARBOR_ENDPOINT/testproject2/nginx:latest
                        sudo docker push $HARBOR_ENDPOINT/testproject2/nginx:latest

                    '''    
                }     
            }
        }


        stage('Test Deploy') {
            steps {
                sh '''
                    sudo kubectl apply -f deployment.yaml
                    sleep 10s
                    sudo kubectl get pods -owide

                '''    
            }
        }
    }

    post { 
        always { 
            sh 'echo "Cleaning workspace..."'
            cleanWs()
            sh 'echo "Done..."'
        }
    }
}