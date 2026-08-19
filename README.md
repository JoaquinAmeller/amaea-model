# amaea-model
Developing an ABM model to analyze food environments

## Supporting documents

- [PSEUDOCODE — HOUSEHOLD FOOD PROCUREMENT PLANNING](https://docs.numerique.gouv.fr/docs/d34e0cb7-cc60-4428-8cf1-ce42acf63910/)
- [AMAEA ODD](https://docs.numerique.gouv.fr/docs/c0c4cd2d-057c-4fc2-9854-2f3c1b0cbc63/)

## How to install it

To install this model into a fresh Pharo image open the Playground (Ctrl+OP) and execute the following Metacello script (select it and press Do-it all button or Ctrl+D). If you already have Cormas installed, then simly execute the second half of the script.

```st
"Install Cormas"
Metacello new
    repository: 'github://cormas/cormas:v0.98';
    baseline: 'Cormas';
    load.

"Install this model"
Metacello new
    baseline: 'AmaeaModel';
    repository: 'github://JoaquinAmeller/amaea-model:main';
    load
```
Or if you want to load a specific version:
```st
"Install Cormas"
Metacello new
    repository: 'github://cormas/cormas:v0.98';
    baseline: 'Cormas';
    load.

"Install this model"
Metacello new
    baseline: 'AmaeaModel';
    repository: 'github://JoaquinAmeller/amaea-model:v0.1.0';
    load
```
