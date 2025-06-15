flutter_build_web: flutter_clean flutter_get
	flutter build web --no-tree-shake-icons --release              

flutter_clean: 
	flutter clean

flutter_get: 
	flutter pub get

	
docker_push_aws: docker_image_remove docker_build_image_aws	
	docker push daruiza/dropbucket_flutter:aws

docker_image_remove:
	docker image rm daruiza/dropbucket_flutter:aws

docker_build_image_aws:
	docker build -f Dockerfile -t daruiza/dropbucket_flutter:aws .
	


