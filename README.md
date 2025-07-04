# 🕌 Qawl

A Quran app for everyone.

Created by Ali Zia and Musa Waseem in 2022.

## Org 

Ali (CEO), Musa (CTO), Soreti (Communications), Abdulsamad (Product), Hashim (SWE Intern), Ebrahim (Media Intern)

```mermaid
graph TD
  Ali[Ali (CEO)]
  Musa[Musa (CTO)]
  Soreti[Soreti (CCO)]

  Samad[Samad (Product)]
  Hashim[Hashim]
  Ebrahim[Ebrahim (Media Intern)]

  Ali --> Hashim
  Musa --> Hashim

  Musa --> Samad
  Soreti --> Samad

  Ali --> Ebrahim
  Musa --> Ebrahim
  Soreti --> Ebrahim
```

Backed by University of Maryland and Prev @ Columbia Startup Accelarator

## About

Primary contributors: Ali Zia, Musa Waseem

Secondary contributors: Abdulsamad Sulayman, Hashim Abdullahi

Contact: qawlapp@gmail.com

**Made with love!**

## Pushing Code (effective 2025)

PRs into `dev` require code reviews by **at least two engineers** your senior (one engineer if that engineer is the CTO). Each new branch must be named with the format `firstname/feature-branch-name`. 

The process is simple: push to your branch, get reviewed, push to `dev`. If it gets approved by the App Store, it'll eventually go to `prod`. 

When a new feature is pushed to `dev` that is over 200 lines of code, **it has to be documented** in the `docs/` folder before it gets into prod. Any AI documentation must be labeled as such. Attempts to push to prod without documentation will be **rejected** in code review. 

Any code that goes into `prod` must be reviewed by Musa or someone he gives direct permission to.

_This repo is now primarily managed by Musa._


## File Structure

📁 Folders

- Screens: All of the primary pages on the app. "Content" is used to denote files containing what you actually see on every screen.
- Widgets: Any of the UI components in a screen
- Model: Any OOP logic, backend, and machine learning integration
- Deprecated: Inactive files in the app

Learn this before you push any code. Your code will be rejected if it does not follow this schema unless given explicit permission by the CTO.

## The Stack

Frontend - Purely Flutter 

Backend - Firebase

## Release
Available on iOS. Just type "Qawl" on the App Store

## Quickstart

1. Install Flutter
2. Install packages, pod install, etc
3. Type "flutter run" in terminal


