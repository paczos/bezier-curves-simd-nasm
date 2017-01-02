#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cstring>
#include <iostream>
using namespace std;
#define _CRT_SECURE_NO_WARNINGS
#define WIDTH 20
#define HEIGHT 10
#define OFFSET (4 - ((WIDTH * 3) % 4))
void bezierPoint(float points[], int size, float t, float t0, float t1, char* pixelArray);
#define CTRL_POINTS 5

void drawbmp(char * filename, char* pixelArray)
{
	// header code taken from https://en.wikipedia.org/wiki/User:Evercat/Buddhabrot.c
	unsigned int headers[13];
	FILE * outfile;
	int extrabytes;
	int paddedsize;
	int red, green, blue;

	extrabytes = 4 - ((WIDTH * 3) % 4);                 // How many bytes of padding to add to each
														// horizontal line - the size of which must
														// be a multiple of 4 bytes.
	if (extrabytes == 4)
		extrabytes = 0;

	paddedsize = ((WIDTH * 3) + extrabytes) * HEIGHT;

	// Headers...
	// Note that the "BM" identifier in bytes 0 and 1 is NOT included in these "headers".

	headers[0] = paddedsize + 54;      // bfSize (whole file size)
	headers[1] = 0;                    // bfReserved (both)
	headers[2] = 54;                   // bfOffbits
	headers[3] = 40;                   // biSize
	headers[4] = WIDTH;  // biWidth
	headers[5] = HEIGHT; // biHeight

						 // Would have biPlanes and biBitCount in position 6, but they're shorts.
						 // It's easier to write them out separately (see below) than pretend
						 // they're a single int, especially with endian issues...

	headers[7] = 0;                    // biCompression
	headers[8] = paddedsize;           // biSizeImage
	headers[9] = 0;                    // biXPelsPerMeter
	headers[10] = 0;                    // biYPelsPerMeter
	headers[11] = 0;                    // biClrUsed
	headers[12] = 0;                    // biClrImportant

	outfile = fopen(filename, "wb");

	//
	// Headers begin...
	// When printing ints and shorts, we write out 1 character at a time to avoid endian issues.
	//

	fprintf(outfile, "BM");
	int n;
	for (n = 0; n <= 5; n++)
	{
		fprintf(outfile, "%c", headers[n] & 0x000000FF);
		fprintf(outfile, "%c", (headers[n] & 0x0000FF00) >> 8);
		fprintf(outfile, "%c", (headers[n] & 0x00FF0000) >> 16);
		fprintf(outfile, "%c", (headers[n] & (unsigned int)0xFF000000) >> 24);
	}

	// These next 4 characters are for the biPlanes and biBitCount fields.

	fprintf(outfile, "%c", 1);
	fprintf(outfile, "%c", 0);
	fprintf(outfile, "%c", 24);
	fprintf(outfile, "%c", 0);

	for (n = 7; n <= 12; n++)
	{
		fprintf(outfile, "%c", headers[n] & 0x000000FF);
		fprintf(outfile, "%c", (headers[n] & 0x0000FF00) >> 8);
		fprintf(outfile, "%c", (headers[n] & 0x00FF0000) >> 16);
		fprintf(outfile, "%c", (headers[n] & (unsigned int)0xFF000000) >> 24);
	}

	//
	// Headers done

	// Write data
	int x; int y;
	for (y = HEIGHT - 1; y >= 0; y--)     // BMP image format is written from bottom to top...
	{
		for (x = 0; x <= WIDTH - 1; x++)
		{

			red = pixelArray[(y*(3*WIDTH +OFFSET))+3*WIDTH] ;
			green = 0;
			blue = 0;
			if (red > 255) red = 255; if (red < 0) red = 0;
			if (green > 255) green = 255; if (green < 0) green = 0;
			if (blue > 255) blue = 255; if (blue < 0) blue = 0;

			// Also, it's written in (b,g,r) format...

			fprintf(outfile, "%c", blue);
			fprintf(outfile, "%c", green);
			fprintf(outfile, "%c", red);
		}
		if (extrabytes)      // See above - BMP lines must be of lengths divisible by 4.
		{
			for (n = 1; n <= extrabytes; n++)
			{
				fprintf(outfile, "%c", 0);
			}
		}
	}

	fclose(outfile);
	return;
}

struct Point
{
	
};
int main()
{

	//de casteljeau for 5 points
	//for one coordinate
	float points[CTRL_POINTS] = { 1.0f, 2.f, 3.f, 4.f, 5};
	char* pixelArray = new char[WIDTH*HEIGHT * 3]; //alloc 3 bytes per pixel

	for (float t = 0.0f; t < 1.f; t += 0.1f)
	{
		float cpoints[CTRL_POINTS];
		memcpy(cpoints, points, sizeof(float) * CTRL_POINTS);
		bezierPoint(cpoints, CTRL_POINTS, t, 0, 1, pixelArray);

	}
	drawbmp("test.bmp", pixelArray);
	delete pixelArray;

	return 0;
}





void bezierPoint(float points[CTRL_POINTS], int size, float t, float t0, float t1, char* pixelArray)
{
	float u = (t - t0) / (t1 - t0);	//normalized progress
	for (int j = 1; j < size; j++)
	{
		for (int i = j; i < size; i++)
		{
			points[i - j] = (1 - u)*points[i - 1] + u*points[i];
		}
		for (int k = 0; k < size; k++)
		{
			std::cout << points[k] << "\t";
		}
	}
	std::cout << endl;
	float x = points[size - 2];

	pixelArray[2*(3*(WIDTH))+(int)x*3] = 100;
}