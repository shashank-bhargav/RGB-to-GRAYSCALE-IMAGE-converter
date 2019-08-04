## Autoencoder for Converting an RBG Image to GRAY scale Image

This an implementation of Undercomplete Autoencoder which is used for converting an RGB image to an GRAY scale image. The autoencoder is implemented using the TensorFlow framework in Python. 


### Packages and the version I used. 

1. TensorFlow==1.11.0
2. Python==3.5.6
3. Numpy==1.15.2
4. OpenCV==3.4.3

Introduction
An Autoencoder is a deep neural network which tries to learn the function f(x) ≈ x or in other words, it learns to copy it’s input to its output. These autoencoders are designed in such a way that they don’t learn to copy the input to output perfectly instead they are restricted in ways that they learn to copy approximately (that’s the reason I wrote f(x) ≈ x instead of f(x) = x), and to copy only input that resembles the training data. This way the model learns prioritize features and learn useful properties of the training data.
The network consists of two parts, an encoder function h = f(x) and a decoder function r = g(h) which are responsible for encoding and reconstruction of the input image.
Encoder
The encoder compresses the input to its latent space representation. The encoder function can be denoted by h = f(x).
Decoder
The decoder reconstructs the image from the latent space representation and it can be denoted by r = f(x).
What’s a Latent space? It is the space where your features lie.
There are different types of Autoencoders such as Undercomplete Autoencoder, Sparse Autoencoder, Denoising Autoencoder, Variational Autoencoders etc. But we are going to focus and use Undercomplete Autoencoder for the problem at hand.
Undercomplete Autoencoder
In the above paragraphs, I have mentioned that we design the autoencoders in a way that they learn to prioritize features/properties from the data (data distribution) by imposing restrictions in architecture (design) of the network. One way to do this by constraining the latent space dimension or have a smaller dimension than the input data (x). This helps the autoencoder to learn salient features from the training data. So, an autoencoder who’s latent space dimension is smaller than the input is known as undercomplete autoencoder. A pictorial representation is given below.

The architecture of an autoencoder.
Autoencoder learns by minimizing the loss function L(x, g(f(x))), where L is a loss function which penalizes g(f(x)) for being dissimilar from x. The g(f(x)) is the encoding and decoding process of the autoencoder (in other words output of the autoencoder). In our case, the loss function is mean squared error and x is an RGB image. The g(f(x)) is reconstructed grayscale image. Th loss function penalized the autoencoder for not being able to reconstruct the grayscale version of the image. Okay, enough of theory let’s start coding!!
Preparing the Dataset for Training and Testing
I have taken the training data for the autoencoder from TensorFlow flower dataset comprising of 3670 flower images and testing data from Olga Belitskaya kernel “The Dataset of Flower Images” from Kaggle. You can download the data from the links I have provided under the heading “Resources” at the bottom of this tutorial. After downloading the training dataset you will see a folder “flower_photos” having subfolders “daisy, dandelion, roses, sunflowers, and tulips” and the test dataset folder name is “flower_images” having flower images.
I. Preparing the training data
To help in preparing the dataset I have used OpenCV and glob library. OpenCV is a computer vision library which has pre-built functions of computer vision algorithms and glob is a Unix style pathname pattern expansion, in simpler terms, based on the rules set by you it would return contents of the particular folder.

line 1- 3: Importing necessary packages.
line 5: The count variable will be used for naming purpose later on
line 7–11: These variables hold path of the respective type of flower photos.
You could see that the names of images in the “flower_photos” subfolders are not proper and for a different type of flower they have a different folder, Hence, we make a unified folder for all the flowers and rename the files in this format “color_<>.jpg” because it would be easier to read programmatically later on.
4. line 13: List of path names over which a loop will be iterated later on.
5. line 17: Reading the names of all the files from the given path of type “.jpg”.
6. line 21–30: Converting the image to grayscale using “cv2.cvtColor(…)” function from OpenCV. Finally, the RGB and grayscale image are renamed and written in their respective new folders.
II. Preparing the Testing Data

line 1–2: Importing the necessary libraries.
line 4: Reading all the file names from the folder “flower_images” of type “.png”.
line 5: Using the count variable later on for naming purpose.
line 7–11: Reads the image and converts into grayscale by using cv2.imread(filename, 0), the zero in the function denotes that function will itself read and convert into a grayscale image, instead of we writing a separate line of code for converting into the grayscale as done in the earlier code snippet.
The training and testing data has been prepared let’s move on to the next step, building the autoencoder.
Building The Autoencoder
I. Importing libraries & Dataset.

This first code snippet helps us preparing the dataset for training the autoencoder. The total number of images are 3670 in the folders “color_images” and “gray_images”. The first image in the “dataset_source” variable has the equivalent grayscale image in “dataset_target” and the indexes are the same.
We want the dimension of the training data to be [3670, 128, 128, 3] which is the input image (color image) and the target image dimension (gray image) as [3670, 128, 128, 1]. So, the lines 9–16 are for reading the color images first, then appending in a Python list and finally using “np.asarray()” to convert into the numpy array.
Similarly, for the grayscale image, the lines 18–24 follows the same procedure as line 9–16 but the dimension obtained from it is [3670, 128, 128] instead of [3670, 128, 128, 1]. So, an extra dimension to the dataset target must be added and this can be done by,

The “np.newaxis” object adds an extra dimension to the “dataset_target” and so the desired dimension [3670, 128, 128, 1] for the target image is obtained. It’s important to have the dimensions mentioned earlier because the Tensorflow placeholders will have the same dimensions. Now the training data has been prepared and stored in the variables “dataset_target” and “dataset_source” variables. Let’s move on to make our autoencoder.
II. Autoencoder Architecture

Why Convolutional Autoencoder (CAE)?
We will be using convolutional autoencoder (CAE) instead of a traditional autoencoder because traditional autoencoder (TAE) doesn’t take into account that a signal could be a composition of other signals. On the other hand, convolutional autoencoder use convolution operator to exploit this observation. They learn to extract the useful set of signals and then try to reconstruct the input. Convolutional autoencoder learns the optimal filters that minimize the reconstruction error instead of manually engineering convolutional filters
line 5–6: The convolutional operation over the image results in an activation map which is wrapped around a non-linear activation function to improve the generalization capabilities of the network. This way the training procedure can learn non-linear patterns in the image. After this, we run a pooling operation on the activation maps to extract dominating features and reduce the dimensionality of the activation maps for efficient computation. (thus we obtain our latent space after the pooling operation)
line 11–12: For upsampling, nearest neighbor interpolation is used which upsamples image by checking the nearest neighbors pixel values. In the next step convolutional operation is performed on the upsampled image to make the network learn the optimal filters for reconstructing the image. We can also use “tf.nn.transpose_conv2d()” function for upsampling and thus leaving the task to the model to learn the optimal filters.
III. Loss Function

Usually, to train the autoencoder the input image and the target image (what the autoencoder must learn to reconstruct) is the same but for our task, the input image is in RGB format and the target image is in grayscale format. This forces the autoencoder to learn the function to convert an RGB image to a grayscale image.
line 1–2: Recall that earlier we prepared the datasets to the dimension quite similar to “tf.placheholder()” function. The “None” represents that the batch size would be determined at the runtime.
line 4: The RGB image is sent as input data to the function “def autoencoder()” which was defined earlier and the function returns the grayscaled image which is stored in the “ae_outputs” variable.
line 7: The difference between the target image (the grayscale desired) with the network generated a grayscale image is obtained and stored it in loss variable.
line 8: We minimize the loss by finding the right set of weights for the network using Adam optimizer.
line 10: Initialize the global variables.
IV. Training the Network

NOTE: CHANGE THE PATH ACCORDING TO YOUR NEED IN THE VARIABLE “saving_path”
line 1–2: Constants such as batch size and epoch size(the number times the dataset must be run over the autoencoder completely, here 50 times.).
line 8–9: The input data to the network is given using the variables “batch_img” (input image) and “batch_out” (target image).
line 11: The network will take 32 images (batch) at once as input hence the need to calculate the total number of batches for 1 epoch for running the inner for a loop at line 18.
line 13–15: Create a session object and run the initializing variable which we defined earlier.
line 20: “sess.run()” runs the computational graph (autoencoder) with the input data and target data what we give.
line 19–20: New images are sent into the network in batches of 32.
The training would take some time depending on your laptop configuration but this produces a good quality grayscale image of the input data after the network has run for 50 epochs.
While training we had saved the model and now we are restoring it for testing purpose. The grayscale converted image are stored in “gen_gray_images” directory.
