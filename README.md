# RRC-60
This repository is created to publish the <i>Roman Republican Coins</i> - 60 (RRC-60) dataset and experimental settings that we followed in our paper <a href="https://www.sciencedirect.com/science/article/pii/S0167865519303708"> Sinem Aslan, Sebastiano Vascon, and Marcello Pelillo. "Two Sides of the Same Coin: Improved Ancient Coin Classification Using Graph Transduction Games." Pattern Recognition Letters (2019) </a>

In the creation of this dataset we referred to a previous public dataset of [2] with 180 images of reverse (motif) sides of 60 coin types from Roman Republican period which we also experimented on at [1]. Thus, abiding by the same coin types with [2] (except five types shown below) we created a new dataset with larger quantity and diversity, i.e. we collected 100 images for each side of the 60 coin types, which in the end resulted with 6000 image pairs for each coin specimen. Images are collected from <a href = 'https://www.acsearch.info/'>acsearch.info</a> and <a href = 'http://numismatics.org/crro/'>Coinage of the Roman Republic Online (CRRO)</a>. Since we could not reach sufficient quantity of images for a few classes of [2], by discarding those types we selected another five coin types from Republican Rome which look quite similar to the previous ones.  Observe-side and reverse-side images of a coin selected from five replaced classes of the dataset in [2] are shown below. 
| <b> First row: Classes of the dataset in [2], Second row: New classes in RRC-60 dataset. </b>|
|:--:| 
| ![changed_classes](https://user-images.githubusercontent.com/7011371/71901503-620f1b00-3160-11ea-866a-e431c89ee098.png)| 
|:--:| 
| <b>1st column:</b> 258/1 (Caesar) and 257/1 (Vargunteius), <b>2nd column:</b> 370/1a-b (Serveilius) and 264/1 (Serveilius), <b>3rd column:</b> 169/1 (Anonymious) and 219/1a-e (Antestius), <b>4th column:</b> 451/1 (Pansa) and 449/1a (Pansa), <b>5th column:</b> 462/1a-c (Cato) and- 343/1c (Cato). |


|Intra-class variations in RRC-60 due to illumination differences, degradations and dirt on the surfaces of the coins. Each row depicts images of observe-side and reverse-side of three coins selected from the same class. |
|:--:| 
|![degradations_3](https://user-images.githubusercontent.com/7011371/71903543-9b498a00-3164-11ea-8508-3d72e13cc05f.png)|
|:--:| 
| First row: Class 60 (Cra489/5-6); Second row: Class 59 (Cra 489/2-3); and Third row: Class 53 (Cra 543/1).|

 




We present an example image from previous and recent classes in Fig. 1 with their Crawford numbers and issuer name.

Dataset images (around 4GB) can be reached from https://drive.google.com/file/d/16EpvOJQe0Z-Zbv0SD_4igc_nY94WcaTj/view?usp=sharing

If you use RRC-60 dataset, please cite to  <a href="https://www.sciencedirect.com/science/article/pii/S0167865519303708"> Sinem Aslan, Sebastiano Vascon, and Marcello Pelillo. "Two Sides of the Same Coin: Improved Ancient Coin Classification Using Graph Transduction Games." Pattern Recognition Letters (2019) </a>




------------------------------

[1] S. Aslan,  S. Vascon,  and M. Pelillo.   Ancient coin classification usinggraph transduction games.2018 IEEE Int. Conf. on Metrology for Archaeology and Cultural Heritage, 2018 (In Press).

[2] S. Zambanini and M. Kampel.  Coarse-to-fine correspondence search forclassifying ancient coins. In Asian Conference on Computer Vision, pages25–36, 2012
