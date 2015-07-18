# Introduction #

PureFoundation is a clone of Apple's Foundation.framework. It is designed exclusively for use with Darwin, and uses CFLite and the Objective-C 2.0 runtime (and, one day, the AutoZone garbage collector). One side effect of this is binary compatibility with a subset of tools and applications compiled on OS X.

The primary goal of PureFoundation is to provide the features necessary to allow the creation of a self-contained Darwin system. Objective-C is a great programming language and Foundation is a mature and fully-featured programming library, so it's hardly surprising that Apple uses it extensively in the development of both OS X and Darwin. However, this has left us in the position where several key components released as open source as part of Darwin cannot run without Foundation, which hasn't been (and is unlikely ever to be) released as open source. The alternative to cloning Foundation is to re-write these components using another language and library.

## Hasn't this been done before? ##

There are already a number of open source projects which aim to achieve a similar goal. GNUStep and Cocotron are the most prominent of these. PureFoundation will certainly reuse some source code from each of these projects. PureFoundation, however, differs in that it starts by building on CFLite. This provides implementations of core library objects - collections, strings, OS abstractions - which are identical to those used by Apple, and also means development is much faster.