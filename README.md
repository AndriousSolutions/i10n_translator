# i10n_translator
*Supply Translations to your Flutter app.*
[![Medium](https://img.shields.io/badge/Medium-Read-green?logo=Medium)](https://medium.com/@greg.perry/do-you-speak-a-my-language-587854c2d0a3) [![Pub.dev](https://img.shields.io/pub/v/i10n_translator.svg?logo=data:image/png;base64,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)](https://pub.dev/packages/i10n_translator) [![GitHub stars](https://img.shields.io/github/stars/AndriousSolutions/i10n_translator.svg?style=social&amp;logo=github)](https://github.com/AndriousSolutions/i10n_translator/stargazers) 

The idea behind this library package is to allow your app to easily display its text in any number of supported translations. Those translations are stored in a human-readable and easy-to-update format to be accessed by developers and non-developers alike.
#### Sample App
There is a sample app available to you on Github to see how this library package can be implemented and used in your Flutter app: [Shrine MVC](https://github.com/Andrious/shrine_mvc)
#### Installing
I don't always like the version number suggested in the '[Installing](https://pub.dev/packages/i10n_translator#-installing-tab-)' page.
Instead, always go up to the '**Major**' value in the semantic version number when installing my library packages. This means always entering a version number with then two trailing zeros, '**.0.0**'. This allows you to take in any '**minor**' versions introducing new features, or in this case, any '**patch**' versions that involves bugfixes. Semantic version numbers are always in this format: **major.minor.patch**. 

1. **patch** - I've made bugfixes
2. **minor** - I've introduced new features
3. **major** - I've essentially made a new app. It's broken backwards-compatibility and has a completely new user experience. You won't get this version until you increment the **major** number in the pubspec.yaml file.

And so, in this case, add this to your package's pubspec.yaml file instead:
```javascript
dependencies:
  i10n_translator:^1.0.0
```
#### A CSV File
A text file is used to contain the translations separated by commas. It is commonly called a CSV file and is readily recognized by many editors including MS Excel. This allows 'non-developers' for example to easily enter the text translations for your Flutter app. Below is a screenshot of the CSV file named, i10n.csv, displayed in the simple Windows text editor called, Notepad.
![i10ncsv](https://user-images.githubusercontent.com/32497443/67162744-c625fe00-f32c-11e9-98b8-807e31dda8bd.png)
As you see below, this text file is easily read in by Microsoft Excel presenting the text and its translations in a nice easy-to-read tabular form. You can see there's an English column, a French column and a Spanish column. You're free to insert blank lines, but every column must be filled or it won't be included in your Flutter app. Further note, the text is case-sensitive. 
![i10nExcel](https://user-images.githubusercontent.com/32497443/67162830-aba05480-f32d-11e9-9d60-bef35f5ed0cb.png)
Below is a screenshot of the resulting code generated from the CSV file. Note, you do have the option to not generate the code at all and instead have your Flutter app 'read in' this CSV file directly at start up. Thus providing those translations! I'll explain that option later on. For now, let's see how you'd use this generated code below.
![i10nTrans](https://user-images.githubusercontent.com/32497443/67162883-64ff2a00-f32e-11e9-89f4-c78c0a638692.png)
In the screenshot above, you see there's now a Map object called, *i10nWords*, that contains all the translations currently available to your Flutter app. The sample app below, for example, takes in that object with an *import* statement and then supplies that object to the library package's **init**() function.
![i10nWords](https://user-images.githubusercontent.com/32497443/67162913-c45d3a00-f32e-11e9-9ff2-7095becbafa6.png)
#### Example Sample App
As it happens, when you run the sample app, [Shrine MVC](https://github.com/Andrious/shrine_mvc), you've the means to manually 'switch' between the default text and two translations (French and Spanish). There's a menu option allowing you to do just that. The screenshots below depict the change, for example, from English to French. Notice the labelled names of the photos then change accordingly.
![i10nShrineMVC](https://user-images.githubusercontent.com/32497443/67163187-988f8380-f331-11e9-8e56-5759bd1a373b.png)
Below is the screenshot of the code in the Sample app that displays those items and they're corresponding labels. You can see the default strings, in this case, are in English. However, note when looking at the list of Product objects below, the named parameter, name, is not being supplied a string value directly but are instead being supplied the static function, **s**(), from the library package, *i10n_translator*. Which, in turn, takes in the strings. It's there where the translation is performed and returned to the named parameter, name.
![i10nSFuncs](https://user-images.githubusercontent.com/32497443/67163252-4f8bff00-f332-11e9-8f40-cb204f37706f.png)
<img src="https://cdn-images-1.medium.com/max/1000/1*ZBJGs93q1bI9_LyHn_nGLw.gif" alt="ShrinApp" width="200"/>
#### Keep It Simple
Again, the idea is to provide the translations in a simple text file with its columns delimited by commas. It's assumed the 'default' language is the first column. You would provide those text strings in the app itself to the static function **s**() or **t**(). However, they then serve as a 'key' field when reading this CSV file. Again, as a key field, the first column is case-sensitive.
![i10nTabular](https://user-images.githubusercontent.com/32497443/67163345-6a12a800-f333-11e9-8092-6740ec7b778b.png)
Once the translations are ready, you've the option now to generate the code to then supply those translations to your Flutter app. Note, before you can do this, you do have to reference the library package in your pubspec.yaml file.
![i10npubspecyaml](https://user-images.githubusercontent.com/32497443/67163370-ad6d1680-f333-11e9-8530-33ea9554f52b.png)
#### Type The Command
And so now using your IDE editor terminal window, you're free to reference the specific class in the library package to generate the resulting dart file:

`flutter pub run i10n_translator test.csv path/destination/dart file`

Simply referencing the class without any arguments, and you will have that class then assume the following input file and resulting dart file:

`flutter pub run i10n_translator [i10n.csv] [i10nwords.dart]`

#### Or Not
If you're innately lazy and don't like typing like me, you can, for example, use Android Studio and create a 'Dart command line app' that instead points directly to the library package file, *i10n_translator.dart*.
![i10nTranslatorCommand](https://user-images.githubusercontent.com/32497443/67163419-3421f380-f334-11e9-8d0a-c835c3b1e89f.png)
You can see below how that configuration is set up:
![i10nConfiguration](https://user-images.githubusercontent.com/32497443/67163430-6e8b9080-f334-11e9-80ea-437a6e742ca2.png)
Below is a screenshot of the i10n_translator.dart file being called in the configuration above. You can see there's a **main**() function there that calls the library package class, *I10nTranslator*, supplying the two arguments if any to the function, **generate**().
![i10nMain](https://user-images.githubusercontent.com/32497443/67163467-ed80c900-f334-11e9-87c1-e5069306d154.png)
#### Just The CSV File
Again, I'm lazy. I don't want to do that 'extra step' of generating the code to display the translations. I've got this CSV file now, and so why don't I just use that file?? You can too! Look at the screenshot of the Sample app below. See what I've done? There's nothing passed into the **init**() function.
![i10nShrineApp](https://user-images.githubusercontent.com/32497443/67163624-aabff080-f336-11e9-9d80-27270f7ebf74.png)
I simply include that CSV text file as an asset to the Flutter app instead and have the library package read it in at start up to supply the translations. By default, this library package will look for the CSV file in the assets directory under the folder, *i10n*: `assets/i10n/i10n.csv`. And so, you then specify that location and file in the pubspec.yaml file.
![i10nCSVYaml](https://user-images.githubusercontent.com/32497443/67163673-5ec17b80-f337-11e9-8b7c-f876e61049cd.png)
#### Continue on Medium
Below is an the corresponding article to this README file. Click on it for further information about this library package:
[![SpeakAMyLanguage](https://user-images.githubusercontent.com/32497443/67603789-776ad080-f73f-11e9-8ce8-2eb2cef21fac.jpg)](https://medium.com/@greg.perry/do-you-speak-a-my-language-587854c2d0a3#c9dc)
##### Other Dart Packages
[![packages](https://user-images.githubusercontent.com/32497443/64993716-5c818280-d89c-11e9-87b5-f35aee3e22f4.jpg)](https://pub.dev/publishers/andrioussolutions.com/packages)
Other Dart packages from the author can also be found at [Pub.dev](https://pub.dev/publishers/andrioussolutions.com/packages)