# i10n_translator
*Supply Translations to your Flutter app.*

The idea behind this library package is to allow your app to easily display its text in any number of supported translations. Those translations are stored in a human-readable and easy-to-update format to be accessed by for developers and non-developers alike.
###### Sample App
There is a sample app available to you on Github to see how this library package is implemented and used in your Flutter app: [Shrine MVC](https://github.com/Andrious/shrine_mvc)

##### A CSV File
A text file is used to contain the translations separated by commas (commonly called a CSV file) is readily recognized by many editors including MS Excel. This allows 'non-developers' for example to easily enter the text translations for your Flutter app. Below is a screenshot of the CSV file named, i10n.csv, displayed in the simple Windows text editor called, Notepad.
![i10ncsv](https://user-images.githubusercontent.com/32497443/67162744-c625fe00-f32c-11e9-98b8-807e31dda8bd.png)
As you see below, this text file is easily read in by Microsoft Excel presenting the text and its translations in a nice easy-to-read tabular form. You can see there's an English column, a French column and a Spanish column. You're free to insert blank lines, but every column must be filled or it won't be included in your Flutter app. Further note, the text is case-sensitive. 
![i10nExcel](https://user-images.githubusercontent.com/32497443/67162830-aba05480-f32d-11e9-9d60-bef35f5ed0cb.png)
Below is a screenshot of the resulting code generated from the CSV file. Note, you do have the option to not generate the code at all and instead have your Flutter app 'read in' this CSV file directly at start up. Thus providing those translations! I'll explain that option later on. For now, let's see how you'd use this generated code below.
![i10nTrans](https://user-images.githubusercontent.com/32497443/67162883-64ff2a00-f32e-11e9-89f4-c78c0a638692.png)
In the screenshot above, you see there's now a Map object called, *i10nWords*, that contains all the translations currently available to your Flutter app. The sample app below, for example, takes in that object with an import statement and then supplies that object to the library package's **init**() function.
![i10nWords](https://user-images.githubusercontent.com/32497443/67162913-c45d3a00-f32e-11e9-9ff2-7095becbafa6.png)
##### Example Sample App
As it happens, when you run the sample app, [Shrine MVC](https://github.com/Andrious/shrine_mvc), you've the means to manually 'switch' between the default text and two translations (French and Spanish). There's a menu option allowing you to do just that. The screenshots below depict the change, for example, from English to French. Notice the labelled names of the photos then change accordingly.
![i10nShrineMVC](https://user-images.githubusercontent.com/32497443/67163187-988f8380-f331-11e9-8e56-5759bd1a373b.png)
Below is the screenshot of the code in the Sample app that displays those items and they're corresponding labels. You can see the default strings, in this case, are in English. However, note when looking at the list of Product objects below, the named parameter, name, is not being supplied a string value directly but are instead being supplied the static function, **s**(), from the library package, *i10n_translator*. Which, in turn, takes in the strings. It's there where the translation is performed and returned to the named parameter, name.
![i10nSFuncs](https://user-images.githubusercontent.com/32497443/67163252-4f8bff00-f332-11e9-8f40-cb204f37706f.png)
![ShrinApp](https://cdn-images-1.medium.com/max/1000/1*ZBJGs93q1bI9_LyHn_nGLw.gif)
##### Keep It Simple
Again, the idea is to provide the translations in a simple text file with its columns delimited by commas. It's assumed the 'default' language is the first column. You would provide those text strings in the app itself as you normally would. However, they then serve as a 'key' field when reading this CSV file. Again, as a key field, the first column is case-sensitive.
![i10nTabular](https://user-images.githubusercontent.com/32497443/67163345-6a12a800-f333-11e9-8092-6740ec7b778b.png)
Once the translations are ready, you've the option now to generate the code to then supply those translations to your Flutter app. Note, to supply that option, you do have to set up things in your app's pubspec.yaml file.
![i10npubspecyaml](https://user-images.githubusercontent.com/32497443/67163370-ad6d1680-f333-11e9-8530-33ea9554f52b.png)
And so now using your IDE editor terminal window, you're free to reference the specific class in the library package to generate the resulting dart file:
`flutter pub run i10n_translator test.csv path/destination/dart file`
Simply referencing the class without any arguments, and you will have that class then assume the following input file and resulting dart file:
`flutter pub run i10n_translator [i10n.csv] [i10nwords.dart]`
If you're innately lazy and don't like typing like me, you can, for example, use Android Studio and instead create a 'Dart command line app' that instead points directly to the library package file, i10n_translator.dart.
![i10nTranslatorCommand](https://user-images.githubusercontent.com/32497443/67163419-3421f380-f334-11e9-8d0a-c835c3b1e89f.png)
You can see below how that configuration is set up:
![i10nConfiguration](https://user-images.githubusercontent.com/32497443/67163430-6e8b9080-f334-11e9-80ea-437a6e742ca2.png)
Below is a screenshot of the i10n_translator.dart file being called in configuration above. You can see there's a **main**() function there that calls the library package class, *I10nTranslator*, supplying the two arguments if any to the function, **generate**().
![i10nMain](https://user-images.githubusercontent.com/32497443/67163467-ed80c900-f334-11e9-87c1-e5069306d154.png)
##### Just The CSV File
Again, I'm lazy. I don't want to do that 'extra step' of generating the code to display the translations. I've got this CSV file now, and so why don't I just use that file?? You can too! Look at the screenshot of the Sample app below. See what I've done?
![i10nShrineApp](https://user-images.githubusercontent.com/32497443/67163624-aabff080-f336-11e9-9d80-27270f7ebf74.png)
I simply include that text file as an asset to the Flutter app and have the library package read it in at start up to supply the translations. By default, this library package will look for the CSV file in the assets directory under the folder, *i10n*: `assets/i10n/i10n.csv`. And so, you then specify that location and file in the pubspec.yaml file.
![i10nCSVYaml](https://user-images.githubusercontent.com/32497443/67163673-5ec17b80-f337-11e9-8b7c-f876e61049cd.png)