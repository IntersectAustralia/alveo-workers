## Introduction

This repository contains the implementation of a set of "workers" to aid the ingestion of corpora into Alveo. The workers implement the producer-consumer pattern where work is either consumed off a work queue or produced by being placed on it. This pattern serves two purposes, firstly to act as a buffer for tasks that may take some time, and secondly to allow scalability through the increase or decrease in the number of wokers.

## System Overview

### Core System

![Core System](img/workers1.png)

The core of the system includes a server running the message queue, three servers running the data stores (Sesame, Solr, Postgres), and another server hosts the workers. There are four types of workers: Upload, Sesame, Solr, and Postgres. The 
Upload worker does the vast majority of the actual work: it takes messages containing JSON-LD formatted metadata off the upload queue and generates messages for the other workers and puts them on their queues. The workers named after their respective data stores are then responsible for taking messages off their queues and storing the data within in their stores.

### Greater System

![Greater System](img/workers2.png)

### Scaling Ingest


## Worker Overview

### life cycle

### Batching





