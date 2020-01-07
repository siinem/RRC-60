# RRC-60
This repository is created to publish the <i>Roman Republican Coins</i> - 60 (RRC-60) dataset and experimental settings that we followed in our paper <a href="https://www.sciencedirect.com/science/article/pii/S0167865519303708"> Sinem Aslan, Sebastiano Vascon, and Marcello Pelillo. "Two Sides of the Same Coin: Improved Ancient Coin Classification Using Graph Transduction Games." Pattern Recognition Letters (2019) </a>

In the creation of this dataset we referred to a previous public dataset of [2] with 180 images of reverse (motif) sides of 60 coin types from Roman Republican period which we also experimented on at [1]. Thus, abiding by the same coin types with [2] (except five types shown below) we created a new dataset with larger quantity and diversity, i.e. we collected 100 images for each side of the 60 coin types, which in the end resulted with 6000 image pairs for each coin specimen. Images are collected from <a href = 'https://www.acsearch.info/'>acsearch.info</a> and <a href = 'http://numismatics.org/crro/'>Coinage of the Roman Republic Online (CRRO)</a>. Since we could not reach sufficient quantity of images for a few classes of [2], by discarding those types we selected another five coin types from Republican Rome which look quite similar to the previous ones. Exchanged classes are shown below. 

| ![changed_classes](https://user-images.githubusercontent.com/7011371/71901503-620f1b00-3160-11ea-866a-e431c89ee098.png)| 
|:--:| 
| Observe-side and reverse-side images of a coin selected from five replaced classes of the dataset in [2]. First row: Classes of the dataset in [2], Second row: New classes in RRC-60 dataset. First column: 258/1 (Caesar) and- 257/1 (Vargunteius), Second column.: 370/1a-b (Serveilius) and- 264/1 (Serveilius), Third column.: 169/1 (Anonymious) and- 219/1a-e (Antestius), Fourth column.: 451/1 (Pansa) and- 449/1a (Pansa), Fifth column.: 462/1a-c (Cato) and- 343/1c (Cato). |




 




We present an example image from previous and recent classes in Fig. 1 with their Crawford numbers and issuer name.

Dataset images (around 4GB) can be reached from https://drive.google.com/file/d/16EpvOJQe0Z-Zbv0SD_4igc_nY94WcaTj/view?usp=sharing

If you use RRC-60 dataset, please cite to  <a href="https://www.sciencedirect.com/science/article/pii/S0167865519303708"> Sinem Aslan, Sebastiano Vascon, and Marcello Pelillo. "Two Sides of the Same Coin: Improved Ancient Coin Classification Using Graph Transduction Games." Pattern Recognition Letters (2019) </a>




------------------------------

[1] S. Aslan,  S. Vascon,  and M. Pelillo.   Ancient coin classification usinggraph transduction games.2018 IEEE Int. Conf. on Metrology for Archaeology and Cultural Heritage, 2018 (In Press).

[2] S. Zambanini and M. Kampel.  Coarse-to-fine correspondence search forclassifying ancient coins. In Asian Conference on Computer Vision, pages25–36, 2012
