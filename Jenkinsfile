pipeline {
	agent any
    
    environment {

        TKGI_ENDPOINT = "gtcstgvkstka001.globetel.com"
        HARBOR_ENDPOINT = "GTCSTGVKSTHR001.globetel.com"
        CLUSTER_ENDPOINT = "testCluster.globetel.com"
        MASTER_IP = "10.25.164.11"

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
                sh '''
                    ls -al

                    sudo -- sh -c -e "echo $MASTER_IP $CLUSTER_ENDPOINT >> /etc/hosts"
                    sudo docker login -u admin $HARBOR_ENDPOINT -p 27c3@=Ecas
                    sudo docker tag nginx:latest $HARBOR_ENDPOINT/testproject2/nginx:latest
                    sudo docker push $HARBOR_ENDPOINT/testproject2/nginx:latest

                '''        
            }
        }


        stage('Test Deploy') {
            steps {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'tkgiadmin', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) 
                {
                    sh '''
                        sudo chmod +x tkgi-get-credentials.sh
                        tkgi login -a $TKGI_ENDPOINT -u $USERNAME -k -p $PASSWORD
                        sudo ./tkgi-get-credentials.sh $PASSWORD
                        kubectl apply -f deployment.yaml --context testCluster
                        sleep 10s
                        kubectl get pods -o wide

                    '''    
                }  
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