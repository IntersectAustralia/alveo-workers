## Introduction

This repository contains the implementation of a set of "workers" to aid the ingestion of corpora into Alveo. The workers implement the producer-consumer pattern where work is either consumed off a work queue or produced by being placed on it. This pattern serves two purposes, firstly to act as a buffer for tasks that may take some time, and secondly to allow scalability through the increase or decrease in the number of wokers.

## System Overview

### Core System

![Core System](img/workers1.png)

The core of the system includes a server running the message queue, three servers running the data stores (Sesame, Solr, Postgres), and another server hosts the workers. There are four types of workers: Upload, Sesame, Solr, and Postgres. The 
Upload worker does the vast majority of the actual work: it takes messages containing JSON-LD formatted metadata off the upload queue and generates messages for the other workers and puts them on their queues. The workers named after their respective data stores are then responsible for taking messages off their queues and storing the data within in their stores.

### Greater System

![Greater System](img/workers2.png)

The greater system additionally includes the public facing Alveo server, which makes use of the data stores, and an Ingest server. There are two routes to getting jobs onto the work queue. The first is via the Ingester server, which has creates messages and places on the Upload queue (which would perhaps be more aptly named the 'Ingest' queue). It does this by reading RoboChef'd metadata stored on an RDSI mount. This is the private route for getting data into the system, and is analogous to the original ingest method.

The second route is via Alveo's public API. Instead of reading data/metadata off an RDSI mount and formatting it into JSON-LD, the user performs a request to ingest and item and provides the necessary metadata. Alveo performs the authentication/authorisation, and ultimately places the data within the request onto the Upload queue. Once the data has been recieved by the Upload queue, its flow into the rest of the system is the same regardless of the initial route into the system.

### Scaling Ingest

![Scaling Ingest](img/workers3.png)

This architecture affords scalability in each of its individual components. If a particular class of worker is processing slowly, more processes can launched within a Virtual Machine. If the Virtual Machine has its resource maxed out, more Virtual Machines can be launched with more Worker processes running on them. Theses can be transient in the cases where a large ingest task temporarily requires additional resources. If the data store services begin running slowly, they can be scaled into clusters.

## Worker Overview

### life cycle

### Batching

### Launching Workers



