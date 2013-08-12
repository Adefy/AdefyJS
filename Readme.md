AdefyJS
=======

A quick and dirty overview will suffice for now. Ads are built from two main
elements; a load function, and one or more scenes. A package.json file describes
the ad and its dependencies.

Load is called before the ads are meant to be presented, preferably in a
seperate thread. It is expected to load all resources required by the ad scenes
into the native engine. This consists of JS source, and images.

The scenes are then executed one at a time, in order but not at any defined
time, with unpredictable delays between them. As such, ad scene collections are
cached by the device, and any apps requested Adefy ads must first complete
remaining on-device scenes before moving on. This is crucial ofc, continuity is
vital.

Documentation
=============
To generate the docs, run `codo`
