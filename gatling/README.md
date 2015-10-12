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

You can choose between 6 predefined Scenarios (or put your own gatling scenario into the folder):
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

### AWS EC2 t2.micro instance(1 GB Memory / 1 Core)

#### Zooming in from zoom level 10 to 22

50 concurrent users:
================================================================================
---- Global Information --------------------------------------------------------
> request count                                      10350 (OK=10348  KO=2     )
> min response time                                     50 (OK=50     KO=60010 )
> max response time                                  60335 (OK=56103  KO=60335 )
> mean response time                                  2138 (OK=2127   KO=60172 )
> std deviation                                       3023 (OK=2914   KO=162   )
> response time 50th percentile                       1115 (OK=1114   KO=60172 )
> response time 75th percentile                       3127 (OK=3125   KO=60253 )
> mean requests/sec                                 75.919 (OK=75.904 KO=0.015 )
---- Response Time Distribution ------------------------------------------------
> t < 800 ms                                          4545 ( 44%)
> 800 ms < t < 1200 ms                                 756 (  7%)
> t > 1200 ms                                         5047 ( 49%)
> failed                                                 2 (  0%)
---- Errors --------------------------------------------------------------------
> java.util.concurrent.TimeoutException: Request timed out to ec      2 (100.0%)
2-52-30-184-45.eu-west-1.compute.amazonaws.com/52.30.184.45:80...
================================================================================

100 concurrent users:
================================================================================
---- Global Information --------------------------------------------------------
> request count                                      20700 (OK=20643  KO=57    )
> min response time                                     50 (OK=50     KO=60000 )
> max response time                                  60865 (OK=59613  KO=60865 )
> mean response time                                  3947 (OK=3792   KO=60046 )
> std deviation                                       6238 (OK=5505   KO=139   )
> response time 50th percentile                       2000 (OK=1986   KO=60007 )
> response time 75th percentile                       5098 (OK=5063   KO=60009 )
> mean requests/sec                                 82.372 (OK=82.145 KO=0.227 )
---- Response Time Distribution ------------------------------------------------
> t < 800 ms                                          7219 ( 35%)
> 800 ms < t < 1200 ms                                1315 (  6%)
> t > 1200 ms                                        12109 ( 58%)
> failed                                                57 (  0%)
---- Errors --------------------------------------------------------------------
> java.util.concurrent.TimeoutException: Request timed out to ec     57 (100.0%)
2-52-30-184-45.eu-west-1.compute.amazonaws.com/52.30.184.45:80...
================================================================================

150 concurrent users:
================================================================================
---- Global Information --------------------------------------------------------
> request count                                      31050 (OK=30719  KO=331   )
> min response time                                     50 (OK=50     KO=60001 )
> max response time                                  63939 (OK=60554  KO=63939 )
> mean response time                                  5900 (OK=5317   KO=60084 )
> std deviation                                       9411 (OK=7586   KO=391   )
> response time 50th percentile                       2585 (OK=2489   KO=60007 )
> response time 75th percentile                       7307 (OK=7106   KO=60010 )
> mean requests/sec                                 82.302 (OK=81.425 KO=0.877 )
---- Response Time Distribution ------------------------------------------------
> t < 800 ms                                          9765 ( 31%)
> 800 ms < t < 1200 ms                                1915 (  6%)
> t > 1200 ms                                        19039 ( 61%)
> failed                                               331 (  1%)
---- Errors --------------------------------------------------------------------
> java.util.concurrent.TimeoutException: Request timed out to ec    331 (100.0%)
2-52-30-184-45.eu-west-1.compute.amazonaws.com/52.30.184.45:80...
================================================================================

200 concurrent users:
================================================================================
---- Global Information --------------------------------------------------------
> request count                                      41393 (OK=39942  KO=1451  )
> min response time                                      0 (OK=51     KO=0     )
> max response time                                  65479 (OK=61101  KO=65479 )
> mean response time                                  7834 (OK=6515   KO=44148 )
> std deviation                                      12456 (OK=9246   KO=26569 )
> response time 50th percentile                       2979 (OK=2835   KO=60005 )
> response time 75th percentile                       9310 (OK=8673   KO=60009 )
> mean requests/sec                                 84.328 (OK=81.372 KO=2.956 )
---- Response Time Distribution ------------------------------------------------
> t < 800 ms                                         12683 ( 31%)
> 800 ms < t < 1200 ms                                2331 (  6%)
> t > 1200 ms                                        24928 ( 60%)
> failed                                              1451 (  4%)
---- Errors --------------------------------------------------------------------
> java.util.concurrent.TimeoutException: Request timed out to ec   1065 (73.40%)
2-52-30-184-45.eu-west-1.compute.amazonaws.com/52.30.184.45:80...
> java.net.UnknownHostException: ec2-52-30-184-45.eu-west-1.comp    385 (26.53%)
ute.amazonaws.com
> java.net.UnknownHostException: ec2-52-30-184-45.eu-west-1.comp      1 ( 0.07%)
ute.amazonaws.com: unknown error
================================================================================

