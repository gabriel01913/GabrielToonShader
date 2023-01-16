# Gabriel Toon Shader Manual

# Sumary
- [What we trying to acomplish?](./GTShader_Manual.md#what-we-trying-to-acomplish?)
  - [Genshin Style](./GTShader_Manual.md#genshin-style)
  - [Guilt Gear Strive Style](./GTShader_Manual.md#guilt-gear-strive-style)


# What we trying to acomplish?

The first thing to question is: “What make a Anime looks like a Anime?”.
Thats alot of style of animes, and each artist have their own way to draw, but we need a guidline to folow to achive something, so lets check de image below:

<img width = "800" src="Image/UT2018_UTS2_SuperTips_10.png">

[Source](https://docs.unity3d.com/Packages/com.unity.toonshader@0.6/manual/instruction.html)

The imagem separate the colors by they intentions:
1 - The hi Color, represents the reflection of the light on a surface.
2 - The base color, that is the lit base color of the character.
3 - The 1st Shade, that is the unlit base color.
4 - The 2st Shade, is like a deep, dark shadow.
I try to achieve these principles with layers of shading, using lerp, and lambert methods for calculating light, the most common technic, nothing revolutionary here.
Plus the colors there outlines, the lines that define the shape of the character, whereas the silhouette begins and end.

<img width = "800" src="Image/outline.jpg">

[Source](https://img.freepik.com/premium-vector/drawing-process-young-man-anime-style-character-vector-illustration-design_18591-62206.jpg?w=2000)

Theres a lot of technics to achieve outlines, but in this repository I focus on the basic, inverted hull method that a will explain later.

# Genshin Style

Genshin Impact is a game developed by miHoYo, is a chinese company, that make games with a anime style.
The texture pipeline for achieve this visual, is not too mucn different then a PBR pipeline, their use the same pipeline texture, like albedo texture, normal map, height map, and so on.
The differences is that their divide the enviroment and the character in two render pipelines, wheres the character pipeline focus and achieving and more acurrated anime style, and the enviroment focus on a more waterpaint style, that works really good together.
[Here you can watch the miHoYo talk about the render pipelines](https://www.youtube.com/watch?v=egHSE0dpWRw&ab_channel=UnityKorea)

<img width = "800" src="Image/genshinayakaleakmain.jpg">

<img width = "800" src="Image/genshinDemo.png">


# Guilt Gear Strive Style

Arc System Works, create something new on the realese of their game Guilty Gear Xrd -SIGN-, make 3D models look as like a 2D sprite.

<img width = "800" src="Image/ggXrd.png">

Is not perfect, but is impressive how close did they get.
