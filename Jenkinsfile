pipeline {
	agent { 
        label 'jenkins-worker-dif-tkgi' 
    }
    environment {

        TKGI_ENDPOINT = "gtcstgvkstka001.globetel.com"
        HARBOR_ENDPOINT = "GTCSTGVKSTHR001.globetel.com"
        CLUSTER_ENDPOINT = "nonProdTestCluster.dif.globetel.com"
        MASTER_IP = "10.25.164.2"

    }

    stages {

        stage('Code Checkout') {
            steps {
                checkout([  
                    $class: 'GitSCM', 
                    branches: [[name: "master"]],
                    doGenerateSubmoduleConfigurations: false, 
                    extensions: [], 
                    submoduleCfg: [], 
                    userRemoteConfigs: [[credentialsId: 'satkgiharbor', url: 'https://github.com/acebern/CaaS-TKGI_Test-Deployment.git']]
                    ])
            }
        }  

        stage('Prepare') {
            steps {
                withCredentials([file(credentialsId: 'harbor-cert', variable: 'HARBOR_CERT')]) 
                {
                    sh '''
                        sudo systemctl start docker
                        sudo yum install expect -y
                        sudo docker pull nginx
                        sudo mkdir -p /etc/docker/certs.d/$HARBOR_ENDPOINT
                        sudo cp $HARBOR_CERT /etc/docker/certs.d/$HARBOR_ENDPOINT/ca.crt

                    '''

                }
            }
        }  

        stage('Cluster Authentication and Image Push to Harbor') {
            steps {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'devopsadmin', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) 
                {
                    sh '''

                        ls -al

                        chmod +x tkgi-get-credentials.sh
                        sudo -- sh -c -e "echo $MASTER_IP $CLUSTER_ENDPOINT >> /etc/hosts"

                        tkgi login -a $TKGI_ENDPOINT -u $USERNAME -k -p $PASSWORD
                        tkgi clusters

                        ./tkgi-get-credentials.sh $PASSWORD

                        kubectl get nodes

                        sudo docker login -u devopsadmin $HARBOR_ENDPOINT -p $PASSWORD
                        sudo docker tag nginx:latest $HARBOR_ENDPOINT/testproject2/nginx:latest
                        sudo docker push $HARBOR_ENDPOINT/testproject2/nginx:latest

                    '''    
                }     
            }
        }


        stage('Test Deploy') {
            steps {
                sh '''
                    kubectl apply -f deployment.yaml
                    sleep 10s
                    kubectl get pods -owide

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