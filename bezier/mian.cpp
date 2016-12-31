#include<iostream>
using namespace std;

float deCasteljeau(float points[], int size, float t, float t0, float t1);

int main()
{

	//de casteljeau for 5 points
	//for one coordinate
	float points[] = { 1.f, 2.f, 3.f, 4.f };

	float res = deCasteljeau(points, 4, 0.5, 0, 1);

	return 0;
}

float deCasteljeau(float points[], int size, float t, float t0, float t1)
{
	float u = (t - t0) / (t1 - t0);	//normalized progress
	for (int j = 1; j <= size; j++)
	{
		for (int i = j; i <= size; i++)
		{
			points[i - 1] = (1 - u)*points[i - 1] + u*points[i];
		}
	}
	return points[size-2];
}