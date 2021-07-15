# practica-2-despliegue-continuo

## Pasos de configuración de la aplicación 

Se han realizado los siguientes pasos para realizar el canary
### Generar imágenes Docker
```
mvn spring-boot:build-image -DskipTests -Dspring-boot.build-image.imageName=parlaga/4.4-p.2-library:v[1-4]
docker push parlaga/4.4-p.2-library:v[1-4]
```

### Levantar cluster
```
minikube start --memory 8192 --driver virtualbox --cpus 4
minikube addons enable istio-provisioner
minikube addons enable istio
minikube addons enable metrics-server
```
### Instalar flagger
[Instrucciones aquí](https://docs.flagger.app/install/flagger-install-on-kubernetes)

Para monitorizar los canaries, flagger provee un dashboard en grafana
```
helm upgrade -i flagger-grafana flagger/grafana \
--namespace=istio-system \
--set url=http://prometheus.istio-system:9090 \
--set user=admin \
--set password=change-me
```


### Activamos istio en namespace test
```
kubectl label ns test istio-injection=enabled
```

### Desplegamos app y base de datos
```
kubectl apply -f k8s/mysql.yml;
kubectl apply -f k8s/library.yml
```

### Desplegamos canary y gateway 
```
kubectl apply -f k8s/library-canary.yml;
kubectl apply -f k8s/gateway.yml
```

### Desplegamos el servicio para generación de carga
```
kubectl apply -k github.com/weaveworks/flagger//kustomize/tester
```
### Probamos canary actualizando version de aplicación
```
kubectl set image deployments/library-deploy library=parlaga/4.4-p.2-library:v2
kubectl set image deployments/library-deploy library=parlaga/4.4-p.2-library:v3
kubectl set image deployments/library-deploy library=parlaga/4.4-p.2-library:v4
```

### Podemos ver logs del canary
```
kubectl -n istio-system port-forward svc/flagger-grafana 3000:80
```

Acceder a localhost:3000

## Descripción del canary (library-canary.yml):
- Se empieza con 10% de trafico
```yaml
    analysis:
        stepWeight: 10
```

- Incrementa un 10% cada 30 segundos
```yaml
    analysis:
        stepWeight: 10
        interval: 30s
```

- Si llega al 50% se acepta.
```yaml
    analysis:
        stepWeight: 10
        interval: 30s
        maxWeight: 50
```

- Se realizan test de aceptación y de carga sobre el canary
Flagger crea dos servicios para redirigir el tráfico se actualiza la version (primary y canary).
Lanzamos test contra el canary mediante el load tester anteriormente desplegado. 
```yaml
    webhooks:
    - name: acceptance-test
      type: pre-rollout
      url: http://flagger-loadtester.test/
      timeout: 30s
      metadata:
        type: bash
        cmd: "curl -s http://library-canary.test:8881/api/books/ | grep title"
    - name: load-test
      url: http://flagger-loadtester.test/
      timeout: 5s
      metadata:
        cmd: "hey -z 1m -q 10 -c 2 http://library-canary.test:8881/api/books/"
```