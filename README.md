## Introduction

This repository contains the implementation of a set of "workers" to aid the ingestion of corpora into Alveo. The workers implement the producer-consumer pattern where work is either consumed of a work queue or produced by being placed on another queue. This pattern serves two purposes, firstly to act as a buffer for tasks that may take some time, and secondly to allow scalability through the increase or decrease in the number of wokers.

## System overview



## Worker Overview


## Scaling Ingest


