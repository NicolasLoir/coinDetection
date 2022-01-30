from os import listdir
import cv2
from entity_analyse import executeAnalyse
from entity_model_color import createCropWithBackGround
from entity_analyse import createCrop


PHOTO_BRUTE = "../photo/photo_brute/"
PHOTO_CLASSE = '../photo/photo_classe/'

# 1 wide
# 2 normal
# 3 close
# 4 extra wide


def createDataset():
    try:
        idPhotoBrute = 100
        image_path = PHOTO_BRUTE + str(idPhotoBrute) + ".jpg"
        idAnalyse = 4
        listPhoto = executeAnalyse(idAnalyse, image_path)
        img = cv2.imread(cv2.samples.findFile(image_path))
        print("image complete")
        cv2.imshow("image", img)
        cv2.waitKey(0)
        cv2.destroyWindow("image")

        cpt = 0
        for photo in listPhoto:
            x = listPhoto[photo]["x"]
            y = listPhoto[photo]["y"]
            r = listPhoto[photo]["r"]
            img_crop = createCrop(img, x, y, r)
            img_crop_background = createCropWithBackGround(img_crop, r)
            # erreur qui se produit parfois, cf photo brute 55 par exemple
            if len(img_crop) == 0 or len(img_crop_background) == 0:
                print("erreur pour la piece ", cpt)
            else:
                cv2.imshow("img_temp", img_crop_background)
                k = cv2.waitKey(0)
                cv2.destroyWindow("img_temp")
                folder = PHOTO_CLASSE
                if k == ord('1'):
                    folder += '200'
                elif k == ord('2'):
                    folder += '100'
                elif k == ord('3'):
                    folder += '50'
                elif k == ord('4'):
                    folder += '20'
                elif k == ord('5'):
                    folder += '10'
                elif k == ord('6'):
                    folder += '5'
                else:
                    folder += 'bin'

                index = len(listdir(folder)) + 2
                print(folder)
                print(index)
                cv2.imwrite(f'{folder}/P{index:0>3d}.jpg', img_crop_background)
            cpt += 1
    except Exception as e:
        print(e)


createDataset()
