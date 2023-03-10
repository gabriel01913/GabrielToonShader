# Gabriel Toon Shader Manual V1.0

# Sumary
- [What we trying to acomplish?](./GTShader_Manual.md#what-we-trying-to-acomplish?)
  - [Genshin Style](./GTShader_Manual.md#genshin-style)
  - [Guilty Gear Strive Style](./GTShader_Manual.md#guilty-gear-strive-style)
- [The Shader](./GTShader_Manual.md#the-shader)
- [Configuration](./GTShader_Manual.md#configuration)
  - [Shader Worflow](./GTShader_Manual.md#shader-worflow)
  - [Render Face](./GTShader_Manual.md#render-face)
  - [Surface Type](./GTShader_Manual.md#surface-type)
  - [Receive Shadows](./GTShader_Manual.md#receive-shadows)
  - [Is Face](./GTShader_Manual.md#is-face)
- [Textures](./GTShader_Manual.md#textures)
- [Color Ajust](./GTShader_Manual.md#colors-ajust)
- [Ramp Ajust](./GTShader_Manual.md#ramp-ajust)
- [Other Options](./GTShader_Manual.md#other-options)
  - [Additional Light Color Replace](./GTShader_Manual.md#additional-light-color-replace)
  - [Distortion Vertex](./GTShader_Manual.md#distortion-vertex)
  - [Custom UV](./GTShader_Manual.md#custom-uv)
- [Debug Tools](./GTShader_Manual.md#debug-tools)
- [Shadow Mask](./GTShader_Manual.md#shadow-mask)
  - [Shadow Mask Options](./GTShader_Manual.md#shadow-mask-options)
- [Final Toon Shader Controller](./GTShader_Manual.md#final-toon-shader-controller)
- [Vertex Colors](./GTShader_Manual.md#vertex-colors)
- [Outline](./GTShader_Manual.md#outline)
  - [Setup Outline](./GTShader_Manual.md#setup-outline)
  - [Outline Configuration](./GTShader_Manual.md#outline-configuration)
- [ToneMapping](./GTShader_Manual.md#ToneMapping)

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

Genshin Impact is a game developed by miHoYo, is a Chinese company, that make games with an anime style. The texture pipeline for achieving this visual, is not too much different than a PBR pipeline, they use the same pipeline texture, like albedo texture, normal map, height map, and so on. The differences are that they divide the enviroment and the character in two render pipelines, where's the character pipeline focus and achieving and more accurate anime style, and the environment focuses on a more waterpaint style, that works really well together.

[Here you can watch the miHoYo talk about the render pipelines](https://www.youtube.com/watch?v=egHSE0dpWRw&ab_channel=UnityKorea)

<img width = "800" src="Image/genshinayakaleakmain.jpg">

<img width = "800" src="Image/genshinDemo.png">


# Guilty Gear Strive Style

Arc System Works, create something new on the release of their game Guilty Gear Xrd -SIGN-, making 3D models look as like a 2D sprite.

<img width = "800" src="Image/ggXrd.png">

Is not perfect, but is impressive how close did they get. They develop some technics to achieve this look by using a lot of data manipulation, using textures and vertex color as data to give artists the most control they can about the model, and how light will affect the model.

[Here you can watch the 2015 GDC talk about their workflow](https://www.youtube.com/watch?v=yhGjCzxJV3E&ab_channel=GDC)

I will try my best to explain the differences of each style in this manual, and how I incorporated this on my shader.

# The Shader

Lets talk about the shader and the configuration.

You can acess the shader in the Shader menu in the material, in the section **"GabrielShaders"**.

<img width = "400" src="Image/menuShaders.jpg">

<img width = "400" src="Image/menuShaders2.jpg">

And this is the custom edior for the shader.

<img width = "400" src="Image/shaderEditor.jpg">

## Configuration

The first foldout present is the **Configuration**, lets breakdown the options.

<img width = "400" src="Image/shaderEditorConfiguration.jpg">

## Shader Worflow

This option will change some intern shader calculations and enable/disable texture slots.

**Standard**: This option is for a normal PBR workflow, like genshin style, this mode will not added new texture slots.

**GG Strive**: This option is for a Arc System workflow, like GG Strive, this mode will added new texture slots, that is need for this workflow, and will enable vertex colors ajusts.

## Render Face

This option is to choose which face will render.

**Front**: This option will enable render the mesh front faces.

**Back**: This option will enable render the mesh back faces.

**Both**: This option will enable render both faces.

## Surface Type

This option is to choose the surface type.

**Opaque**: This option the material is treated as opaque object.

**Transparent**: This option the material is treated as transparent object, and will enable the blend mode option.

<img width = "600" src="Image/shaderEditorConfigurationBlendMode.jpg">

The transparency is controlled by the alpha channel of the base color.

<img width = "400" src="Image/transparencyAlpha.jpg">
Alpha blend example.

<img width = "400" src="Image/transparencyAdditive.jpg">
Additive blend example

## Alpha Clip

This option will enable/disable the material to clip the fragments, based on a texture mask. When enable new options will appear.

**Alpha Clip Channel** - In wich texture alpha channel has the mask for the clip.

**Clip Threshold** - This is the clip threshold.

<img width = "600" src="Image/alphaclip.jpg">

## Receive Shadows

This option will enable/disable the material to receive shadows casted by others objects, this will not enalbe shadow casting(you enable/disable shadow casting in the rendering component).

## Is Face

This option will enable/disable the material to use a shadow mask texture for the face, instead of the normal lambert calculation.

[Click here for more information](./GTShader_Manual.md#shadow-mask)

# Textures

<img width = "600" src="Image/shaderEditorTexture.jpg">

This section is where you inform the textures.

**Base Texture** - The base color map, lit map, albedo map, theres alot of name for this map, but is the map theres has the lit color of the material. RGB is the colors, and Alpha is genshin workflow is the default for the alpha clip mask, in Arc System workflow the Alpha channel is used for fresnel light intensity, black dont have fresnel white has full intensity.

**Emission Texture** - The emission map, is the texture that contains the emission information. The RGB contains the colors, and Alpha channel the mask.

**Detail Texture** - The detail texture, is the texture that contains the details information. The RGB contains the colors. This texture is multiply by the Base texture, so normaly the details are in black and the rest of the texture is white.

**Normal Map** - The normals map, is the texture that contains data from the normals of the mesh. Theres a process to save in a texture the normals of a high poly count mesh, so you can lower the poly counts but, mantein the details of the normals, this process results in the normal map, so the shader will use the texture informartion when calculate the mesh normals.

**Height Map** - The height map, is a texture that contains data to a process called paralax, that give a fake impression of deep in the mesh.

If "Is Face?" is enabled two new texture slot will appear, to slot the vertical and multidirectional shadow mask textures, respectivily. For more information of this textures [click here](./GTShader_Manual.md#shadow-mask).

<img width = "600" src="Image/shaderEditorTextureShadowMask.jpg">

If "GG Strive" workflow is set, new texture slot will appear.

<img width = "600" src="Image/shaderEditorTextureGG.jpg">

**SSS Texture** - Is the "Sub Surface Scattering" texture of the Arc System workflow. The RGB contains the unlit colors of the mes, and the Alpha Channel is not in use.

**ILM Texture** - Is the ilumination texture, every channel has differences usage to manipulate ilumination data, so lets breakdown.

All texture range values from 0 to 1, black to white.

  - Red Channel contains the intensity of the specular highlight. The value range from 0 to 1(black to white), and are multiply by specular final result. So black means no specular.

<img width = "800" src="Image/ilmRC.png">

  - Green Channel contains a shaded threshold, to define if the area is lit or unlit. 1 means always lit, 0.5 is the default value so lambert will define if is lit or not, 0.25 or lower will make the area unlit, and values below 0.1 will apply the dark shadow color.

<img width = "800" src="Image/ilmGC.png">

  - Blue Channel contains the highlight threshold, to define if the area can have or not highlight, 1 mean always has highlight, 0.5 is the default value so Blinn–Phong will define if is on highlight or not, 0 means no highlight.

<img width = "800" src="Image/ilmBC.png">

  - Alpha Channel contains the inner lines, lines that is hand drawn by the artist. And yes is always in square, because Arc System use a method of square UV so inners lines and textures never breaks continuity.

<img width = "800" src="Image/ilmAC.jpg">

# Colors Ajust

In this section you can ajust the output colors, by giving a color tint, change the intensity or saturation.

<img width = "800" src="Image/baseColor.jpg">

In additional colors you can enable/disable two ramps colors, that is the fresnel light and the specular highlight, and, give the same ajust as the previous colors.

# Ramp Ajust

In this section you can just the ramp values so you can have more control over the render.

<img width = "800" src="Image/rampAjust.jpg">

**Shade Blend Threshold** - This threshold is the blend of the shading, less value more harsh the change of lit and unlit, more value more blend between the colors.

**Shadow Offset** - This offset increase the value that defines if the fragment is lit our unlit, increasing the value makes more susceptible to be in shadows, and vice versa.

**Second Shadow Offset** - This offset increase the value that defines if the fragment is in dark shadows, increasing the value makes more susceptible to be in dark shadows, and vice versa.

<img width = "800" src="Image/shadeOffset.gif">

You can enable/disable, and ajust specular highlight and fresnel in this section.

**Fresnel Size** - This control the size of the fresnel.

**Fresnel Threshold** - This controle the fresnel blend, increase value to remove the blend.

**Frenel Only Shadows** - This options make fresnel appears only in shadows fragments.

<img width = "800" src="Image/fresnelAjust.gif">

**Specular Sizer** - This control the Specular sizer.

<img width = "800" src="Image/specularAjust.gif">

**Remap Shadow Face Rotation** - This value remap the UV rotation range. Only change this value if you want to make the rotation in the multdirectional shadow mask to rotate faster/slower, in relation to the sun. The default value makes the rotation follow the same angles as the directional light.

# Other Options

This section we have some features that i add think is useful to achieve a good anime render and give a little more control over the mesh.

## Additional Light Color Replace

This option enable/disable additional lights(point light, spot light, etc.) to replace the base color with their own colors. When multiple additional lights are present, the shader will prioritise the closer additional lights.

<img width = "800" src="Image/replaceColor.gif">

## Distortion Vertex

This option on enabling remove the projection from the camera on this material, so the object looks like is orthographic in relation to the camera, so give a flat felling, so appears more like is hand drawn.

<img width = "800" src="Image/perspectiveRemoval.gif">

## Custom UV

This configuration on enable give you the option to change the UV index for the texture sample. This is useful if you gona use differents UVs for differents textures.

<img width = "800" src="Image/customUV.jpg">

# Debug Tools

When enable the option "Debug", will can visualize some debug options that the shader provides. The options are:

  - Light Ramps
    - Main Light - Output the ramp of the directional light, only works with one directional light.
    - Additional Light - Output the additional lights mask, as point light, spot lights, etc.
    - Shadow Ramp - Output the lambert shadows ramps.
    - Specular Ramp - Output the Bling-Phong ramp.
    - Fresnel Ramp - Output the fresnel ramp.
    - Face Shadow Mask - Output the face shadow mask.
  - Vertex Colors - Output the vertex colors, you can choose channels individually.
  - ILM Texture - Output the ilm channels colors, you can choose channels individually, plus the base alpha channel.

# Shadow Mask

"Is Face?" option, in the configuration section, will enable/disable the shadow mask texture.

When you make the shadows a harsh change without blend, artificats can appear, and the face is the most commum place to this to happen.

<img width = "600" src="Image/faceArtifacts.jpg">

[Source](https://www.4gamer.net/games/216/G021678/20140703095/)

Genshin workflow minimaze this by using a texture as a shadow mask ramp, especific for the face, so you bypass the artifacts. Arc System dont use texture, **they change the normals vectors for each vertex in the face, by hand**, (personal tough: so much respect for their work!!).

<img width = "400" src="Image/genshinfacemask.jpg">
Example of the genshin mask.

By enable this option, will appear new options and the texture slot for this mask.

<img width = "600" src="Image/shaderEditorConfigurationShadowMask.jpg">

## Shadow Mask Options

**Mask Vertical** - This is a mask for the shadow in the face, but only in vertical position, theres no up down shadows. The gradient is from 0 to 1 from left to right.

Shadow Mask Ramp example.

<img width = "400" src="Image/genshinShadowMask.gif">

With Color.

<img width = "400" src="Image/genshinShadowMask2.gif">

**Mask Multidirectional** - This is a mask, is my own solution, for the shadow in the horizontal position, up down shadows. This mask dont exist in any of the workflow. Theres a catch in this mask, because i need to rotate the uvs, this mask works like a multidirectional shadow ramp.

Shadow Mask Ramp example.

<img width = "400" src="Image/genshinShadowMask3.gif">

With Color.

<img width = "400" src="Image/genshinShadowMask4.gif">

Different from the vertifical texture, this option use texture that is just a gradient from top to bottom.

<img width = "400" src="Image/gradientMultdirectional.png">

**Both** - Use both mask together.

Heres some links can be helpfull for creating your won shadow mask.

[Get *PERFECT* Anime Face Shadows (Easier Way) in Blender](https://www.youtube.com/watch?v=x-K6bCAl6Qs&t=409s&ab_channel=2AM)

[Blender Anime Face Texture Shadow ENG SUB | Nhij Quang](https://www.youtube.com/watch?v=VcaRAhif9ec&t=0s&ab_channel=NhijQuang)

[Shader facial anime Genshin Impact in blender](https://www.youtube.com/watch?v=D3nEolOME50&t=0s&ab_channel=AnimeXDchannel)

But, we need a C# script to constante update the vectors of the face, i created the Final Toon Shader Controller, a componente that need to be added, as parent or in the same game object of the render.

# Final Toon Shader Controller

<img width = "400" src="Image/finalToonShader.jpg">

<img width = "600" src="Image/finalToonShader2.jpg">

To configure the shadow mask we just need to move the game object that represent the sun, and the game object that represents direction of the face, to each slot, and its done. 

The other options is to change multiple materials in the same render. If the mesh has alot of submeshs or alot of differents materials for the same object, you can use this script to change all material as one. Click the **"Start editing"** button to change the values and **"Stop editing"** when is done.

The script will search for materials with the ToonShader shader, in the game object and its childs, but not parents.

# Outline

<img width = "600" src="Image/outlineShader.jpg">

This repository has a outline shader that use the inverted hull method. You can acess the shader in the Shader menu in the material, in the section **"GabrielShaders"**.

The inverted hull method redraw the mesh with front faces culling and moving the fragments by their normal directions and depth, thats making some fragments appears in front of the principal mesh, but the majority away from the mesh, making a effect thats fells like are draw lines arround the character edges. This effect is really expensive because redraw the same mesh twice.

This method only works well when the character is a one single continuity mesh, if the character has submeshes this effect can work but can appears artifact because of the discontinuty in the vertices.

<img width = "800" src="Image/comparisionOutline.jpg">

## Setup Outline

Too add the shader create a new material with this shader and add to the list of the materia of the renderer component.

<img width = "600" src="Image/outlineSetup.jpg">

You can add a render feature and apply this shader as a override.

<img width = "600" src="Image/outlineSetup2.jpg">

## Outline Configuration

**Outline Size** - This configuration ajust the outline size.

**Outline Color** - This configuration ajust the outline color.

**Depth Offset** - This configuration add a value to the depth value, changing this value offset the depth so can remove or add details on the outline.

**Enable Camera Distance Mult** - This configuration enable the outline size are multiple by the camera distance, so bigger outlines when away from the camera, lower when closer to the camera.

**Texture Color Mult** - This configuration enable/disable a texture color for the outline, so differents areas of the mesh can have differentes colors.

**Base Texture** - The texture to be sampled to defines the outline color.

**Distortion Factor** - This effect is to remove perspective of the outline, to match with the character if are using the same feature.

# Vertex Colors

Vertex colors in GG Strive are used as data to manipulate some effects. The values ranges from 0 to 1 (black to white).

**Red Channel** - This channel is another threshold to informa if the fragment is lit or unlit, 1 is the default value so no manipulation, 0.5 is always unlit, 0 is always dark shadows.

**Green Channel** - I do not suport this channel function in this shader, but, the original intention are to shade by the depth of the fragment, far fragments from the camera are more like to be in unlit color.

**Blue Channel** - Is used to manipulate the outline depth, the vertex value is multiple by the depth, 0 means no outline and 1 can have outline.

<img width = "600" src="Image/outlineChannel.jpg">
You can achive effect like this, by removing the outlines. [Source](https://www.4gamer.net/games/216/G021678/20140703095/)


<img width = "600" src="Image/outlineChannel2.jpg">
This show that arround the mouth is black, so no outline will appear in this area.


**Alpha Channel** - Is used to manipulate the outline size, the default value is 0.5, 0 means no outline and 1 means bigger outline.

<img width = "600" src="Image/outlineChannel3.jpg">
The majority of the channel is in grey, 0.5 value, but has some points in black to remove outlines. 

# ToneMapping

This repository contains the Gran Turismo ToneMapping, as a post effect, to achieve a more saturate visual, closer to the anime visual. The idea for using this tonemapping is not mine, i saw this [post](https://www.artstation.com/artwork/wJZ4Gg) that used this tonemapping to achieve a simular result, i liked and replicated.

<img width = "600" src="Image/toneMapping2.jpg">
ToneMapping enable.

<img width = "600" src="Image/toneMapping3.jpg">
ToneMapping disable.

## ToneMapping Configuration

To add this effect you need to add a new render feature in the URP Render Data.

<img width = "600" src="Image/toneMapping.jpg">

**Material** - Is provided in the path *"Assets\GabrielToonShader\RenderFeature\ToneMapingGT"*, use this.

**Maximum Brightness** - This value is the maximum bright value possible, this will make the imagem dark if the value is lower, default value is 1.

**Contrast** - Change the contrats of the final imagem.

**Linear Start** - Changing when the colors start to be linear.

**Linear Lenght** - This changing for how much the linear ramp expand.

**Black Thigness** - This value change the maximum dark value, lowering this value make the dark pixels more dark.

**B** - This is the maximum dark value possible, lowering this value make the image dark, and vice versa, default value is 0.