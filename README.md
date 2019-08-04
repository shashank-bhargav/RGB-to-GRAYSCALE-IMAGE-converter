## Autoencoder for Converting an RBG Image to GRAY scale Image

This an implementation of Undercomplete Autoencoder which is used for converting an RGB image to an GRAY scale image. The autoencoder is implemented using the TensorFlow framework in Python. 

![alt text](https://github.com/akshath123/RGB_to_GRAYSCALE_Autoencoder-/blob/master/sample_output.jpg)

### Packages and the version I used. 

1. TensorFlow==1.11.0
2. Python==3.5.6
3. Numpy==1.15.2
4. OpenCV==3.4.3

*Pre-trained model is present in saved_model.zip.* Load the saved model to skip the training. 

**NOTE: Do check for path errors in the code, modify it according to your need. Eg. The saver.train("....") has a path that must be changed before running the session.**

#### Reference
1. Thanks to people at www.flicker.com for sharing the dataset.
