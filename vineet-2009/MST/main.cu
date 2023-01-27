/***********************************************************************************
Implementing Minimum Spanning Tree on CUDA using Atomic Functions. Part of 
implementation done for the paper:

"Large Graph Algorithms for Massively Multithreaded Architectures"
Pawan Harish, Vibhav Vineet and P.J.Narayanan.
Technical Report IIIT/TR/2009/74, 
International Institute of Information Technology-Hyderabad

Copyright (c) 2009 International Institute of Information Technology - Hyderabad. 
All rights reserved.
  
Permission to use, copy, modify and distribute this software and its documentation for 
educational purpose is hereby granted without fee, provided that the above copyright 
notice and this permission notice appear in all copies of this software and that you do 
not sell the software.
  
THE SOFTWARE IS PROVIDED "AS IS" AND WITHOUT WARRANTY OF ANY KIND,EXPRESS, IMPLIED OR 
OTHERWISE.

Created by Pawan Harish and Vibhav Vineet
************************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <cuda_runtime.h>
#include <chrono>
#include <iostream>
using namespace std::chrono;

//#include "CUDAMST.h"
#include "CUDAMST.cu"

//void MSTGraph(int argc, char** argv);

////////////////////////////////////////////////////////////////////////////////
// Main Program
////////////////////////////////////////////////////////////////////////////////
int main( int argc, char** argv) 
{
	no_of_nodes=0;
	source = 0 ;
	edge_list_size=0;
	MSTGraph( argc, argv);
	exit(0);
}



////////////////////////////////////////////////////////////////////////////////
//Apply MST on a Graph using CUDA
////////////////////////////////////////////////////////////////////////////////
void MSTGraph( int argc, char** argv) 
{
	printf("Reading File\n");
	fp = fopen(argv[1],"r");
	if(!fp)
	{
		printf("Error Reading graph file\n");
		return;
	}

	fscanf(fp,"%d",&no_of_nodes);

	hostMemAllocationNodes();
	// allocate host memory

	printf("Reading %d nodes	",no_of_nodes);
	// initalize the memory
	for(int i = 0; i < no_of_nodes; i++) 
	{
		fscanf(fp,"%d %d",&start,&edgeno);
		h_graph_nodes[i].starting = start;
		h_graph_nodes[i].no_of_edges = edgeno;
		sameindex[i]=i;
		falseval[i]=false;
		trueval[i]=true;
		infinity[i] = INF;
		zero[i]=0;
		h_maxid_maxdegree[i]=-1;

	}

	//read the source node from the file, not needed here though
	fscanf(fp,"%d",&source);

	fscanf(fp,"%d",&edge_list_size);
	printf("Reading %d edges\n",edge_list_size);

	int id,cost;
	hostMemAllocationEdges();

	for(int i=0; i < edge_list_size ; i++)
	{
		fscanf(fp,"%d",&id);
		fscanf(fp,"%d",&cost);
		h_graph_edges[i] = id;
		h_graph_weights[i] = cost;
		h_graph_MST_edges[i] = false;

	}

	if(fp)
		fclose(fp);    

	printf("Finished Reading File\n");

	printf("Copying Everything to GPU memory\n");


	//Copy the Node list to device memory
	
	deviceMemAllocateNodes() ; 
	deviceMemAllocateEdges() ; 
	deviceMemCopy();

	cudaDeviceSynchronize();
	auto start = high_resolution_clock::now();
	GPUMST(); 
	
	// cudaMemcpy( test, d_graph_colorindex, sizeof(int)*no_of_nodes, cudaMemcpyDeviceToHost);
	// for(int i=0;i<no_of_nodes;i++)
	//  {
	// 	 if(test[i]!=0)
	// 	 {
	// 		 printf("All Colors not 0, Error at %d\n",i);
	// 		 break;
	// 	 }
	
	//  }

	int q=0;
	int minimumCost = 0 ; 
	printf("\nFinal edges present in MST\n");
	cudaMemcpy( h_graph_MST_edges, d_graph_MST_edges, sizeof(bool)*edge_list_size, cudaMemcpyDeviceToHost) ;
	for(int i=0;i<int(edge_list_size);i++)
	{
		if(h_graph_MST_edges[i])
		{
			
			int edge = i;
			int edgeweight = h_graph_weights[edge];
			minimumCost += edgeweight; 
			q++;
		}
	}
	printf("No of edges in MST: %d, no of nodes: %d cost %d\n",q,no_of_nodes,minimumCost);
	cudaDeviceSynchronize();
	auto stop = high_resolution_clock::now();
	auto duration = duration_cast<microseconds>(stop - start);
	std::cout << "Finished in: " << duration.count() << std::endl;
	
	freeMem();
		
}
