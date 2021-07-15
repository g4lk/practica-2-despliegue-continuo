# practica-2-despliegue-continuo
## Generar imágenes Docker
```
    mvn spring-boot:build-image -DskipTests -Dspring-boot.build-image.imageName=parlaga/4.4-p.2-library:v[1-4]
    docker push parlaga/4.4-p.2-library:v[1-4]
```

## Levantar cluster
```
    minikube start --memory 8192 --driver virtualbox --cpus 4
    minikube addons enable istio-provisioner
    minikube addons enable istio
```
## Instalar flagger
[Instrucciones aquí](https://docs.flagger.app/install/flagger-install-on-kubernetes)

## Activamos istio en namespace test
```
    kubectl label ns test istio-injection=enabled
```

## Desplegamos app y base de datos
```
    kubectl apply -f k8s/mysql.yml;
    kubectl apply -f k8s/library.yml
```

## Desplegamos canary y gateway 
```
    kubectl apply -f k8s/canary.yml;
    kubectl apply -f k8s/gateway.yml
```
## Probamos canary actualizando version de aplicación
```
    kubectl set image deployments/library-deploy library=parlaga/4.4-p.2-library:v2
    kubectl set image deployments/library-deploy library=parlaga/4.4-p.2-library:v3
    kubectl set image deployments/library-deploy library=parlaga/4.4-p.2-library:v4
```



