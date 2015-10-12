# Tileserver Performance Test with [Gatling](http://gatling.io)


## Usage

Mount configuration and simulation files from host machine and run gatling in interactive mode

```bash
git clone https://github.com/geometalab/osm2vectortiles.git
cd gatling

docker run -it --rm -v $(pwd)/conf:/opt/gatling/conf \
-v $(pwd)/user-files:/opt/gatling/user-files \
-v $(pwd)/results:/opt/gatling/results \
denvazh/gatling
```

## Scenarios

You can choose between 6 predefined Scenarios:
- Zooming in from zoom level 10 to 22 for 50, 100, 150 and 200 concurrent users
- Zooming in form zoom level 10 to 22 move around and zoom out to zoom level 10 for 50, 100, 150 and 200 concurrent users

```bash
Choose a simulation number:
     [0] tileserver.ZoomLevel10InMoveOutConcurrentUsers50Simulation
     [1] tileserver.ZoomLevel10InMoveOutConcurrentUsers100Simulation
     [2] tileserver.ZoomLevel10InMoveOutConcurrentUsers150Simulation
     [3] tileserver.ZoomLevel10InMoveOutConcurrentUsers200Simulation
     [4] tileserver.ZoomLevel10To22ConcurrentUser50Simulation
     [5] tileserver.ZoomLevel10To22ConcurrentUser100Simulation
     [6] tileserver.ZoomLevel10To22ConcurrentUser150Simulation
     [7] tileserver.ZoomLevel10To22ConcurrentUser200Simulation
```
The target [tileserver](http://ec2-52-30-184-45.eu-west-1.compute.amazonaws.com) is set to an Amazon EC2 T2.micro instance. If you want to set the target to your own tileserver, you have to change the tileserver url in the scenario files.

## Results

The results are stored in the results directory. Just open the index.html file and analyze the performance results.
