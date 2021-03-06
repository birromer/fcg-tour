#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpolação da posição global e a normal de cada vértice, definidas em
// "shader_vertex.glsl" e "main.cpp".
in vec4 position_world;
in vec4 normal;

// Posição do vértice atual no sistema de coordenadas local do modelo.
in vec4 position_model;

// Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
in vec2 texcoords;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto está sendo desenhado no momento
#define MUSEU 0
#define ESTANDE 1
#define DINOSSAURO 2
#define TRIANGULO 3
#define VACA 4
#define ESFERA 5
#define CUBO 6
#define ROSQUINHA_1 7
#define ROSQUINHA_2 8
#define LAMPADA 9
#define CHALEIRA_PLANA 10
#define CHALEIRA_CUBICA 11
#define CHALEIRA_ESFERICA 12
#define CHALEIRA_CILINDRICA 13
#define PLANO_GC_REAL 14
#define VETOR_ESTATICO 15
#define VETOR_MOVE 16
#define VETOR_RESULTANTE 17
#define PLANO 18
#define ESFERA_GOURAUD 20
#define ESFERA_BLINN 21


uniform int object_id;

// Parâmetros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

// Variáveis para acesso das imagens de textura
uniform sampler2D TextureImage0;
uniform sampler2D TextureImage1;
uniform sampler2D TextureImage2;
uniform sampler2D TextureImage3;
uniform sampler2D TextureImage4;
uniform sampler2D TextureImage5;
uniform sampler2D TextureImage6;
uniform sampler2D TextureImage7;
uniform sampler2D TextureImage8;
uniform sampler2D TextureImage9;
uniform sampler2D TextureImage10;
uniform sampler2D TextureImage11;
uniform sampler2D TextureImage12;
uniform sampler2D TextureImage13;
uniform sampler2D TextureImage14;
uniform sampler2D TextureImage15;
uniform sampler2D TextureImage16;
uniform sampler2D TextureImage17;
uniform sampler2D TextureImage18;
uniform sampler2D TextureImage19;
uniform sampler2D TextureImage20;
uniform sampler2D TextureImage21;


uniform int estande_atual = 0;
uniform int acerto_ou_erro_est1 = 0;
uniform int cor_lampada = 1;
uniform int direcao_planar = 1;

// O valor de saída ("out") de um Fragment Shader é a cor final do fragmento.
out vec3 color;
vec3 lambert_color;

in vec3 cor_v;

// Parâmetros que definem as propriedades espectrais da superfície
vec3 Kd; // Refletância difusa
vec3 Ks; // Refletância especular
vec3 Ka; // Refletância ambiente
float q; // Expoente especular para o modelo de iluminação de Phong

// Constantes
#define M_PI   3.14159265358979323846
#define M_PI_2 1.57079632679489661923

void main()
{
    // Obtemos a posição da câmera utilizando a inversa da matriz que define o
    // sistema de coordenadas da câmera.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;

    vec4 spotlightPosition = vec4(-22.0,4,0.0,1.0);
    vec4 spotlightDirection = vec4(0.0,-1.0,0.0,0.0);

    // O fragmento atual é coberto por um ponto que percente à superfície de um
    // dos objetos virtuais da cena. Este ponto, p, possui uma posição no
    // sistema de coordenadas global (World coordinates). Esta posição é obtida
    // através da interpolação, feita pelo rasterizador, da posição de cada
    // vértice.
    vec4 p = position_world;

    // Normal do fragmento atual, interpolada pelo rasterizador a partir das
    // normais de cada vértice.
    vec4 n = normalize(normal);

    // Vetor que define o sentido da fonte de luz em relação ao ponto atual.
    //vec4 l = normalize(vec4(1.0,1.0,0.0,0.0));
    vec4 l = normalize(spotlightPosition - p);

    // Vetor que define o sentido da câmera em relação ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // Vetor que define o sentido da reflexão especular ideal.
    vec4 r = -l + 2*n*(dot(n, l));

    // Coordenadas de textura U e V
    float U = 0.0;
    float V = 0.0;

    vec3 Kd0;


    if ( object_id == MUSEU )
    {
        U = texcoords.x;
        V = texcoords.y;
        Kd = texture(TextureImage0, vec2(U,V)).rgb ;

        Ka = vec3(1.000000, 1.000000, 1.000000);
        Ks = vec3(0.500000, 0.500000, 0.500000);
        q = 20.0;

    } else if ( object_id == ESTANDE)
    {
        U = texcoords.x;
        V = texcoords.y;

        if ( acerto_ou_erro_est1 == 1){
            Kd = texture(TextureImage2, vec2(U,V)).rgb ;
        } else if ( acerto_ou_erro_est1 == 2){
            Kd = texture(TextureImage3, vec2(U,V)).rgb ;
        } else {
            Kd = texture(TextureImage1, vec2(U,V)).rgb ;
        }
        Ka = vec3(1.000000, 1.000000, 1.000000);
        Ks = vec3(0.500000, 0.500000, 0.500000);
        q = 20.0;

    } else if ( object_id == DINOSSAURO )
    {
        float x = position_model.x;
        float y = position_model.y;
        float z = position_model.z;

        float absX = abs(x);
        float absY = abs(y);
        float absZ = abs(z);

        bool isXPositive = (x > 0) ? true : false;
        bool isYPositive = (y > 0) ? true : false;
        bool isZPositive = (z > 0) ? true : false;

        float maxAxis, uc, vc;

        // POSITIVE X
        if ((isXPositive) && (absX >= absY) && (absX >= absZ)) {
            maxAxis = absX;
            uc = -z;
            vc = y;
        }
        // NEGATIVE X
        if ((!(isXPositive)) && (absX >= absY) && (absX >= absZ)) {
            maxAxis = absX;
            uc = z;
            vc = y;
        }
        // POSITIVE Y
        if ((isYPositive) && (absY >= absX) && (absY >= absZ)) {
            maxAxis = absY;
            uc = x;
            vc = -z;
        }
        // NEGATIVE Y
        if ((!(isYPositive)) && (absY >= absX) && (absY >= absZ)) {
            maxAxis = absY;
            uc = x;
            vc = z;
        }
        // POSITIVE Z
        if ((isZPositive) && (absZ >= absX) && (absZ >= absY)) {
            maxAxis = absZ;
            uc = x;
            vc = y;
        }
        // NEGATIVE Z
        if ((!(isZPositive)) && (absZ >= absX) && (absZ >= absY)) {
            maxAxis = absZ;
            uc = -x;
            vc = y;
        }

        // Convert range from -1 to 1 to 0 to 1
        U = 0.5f * (uc / maxAxis + 1.0f);
        V = 0.5f * (vc / maxAxis + 1.0f);

        Kd = texture(TextureImage4, vec2(U,V)).rgb ;

        Ka = vec3(1.000000, 1.000000, 1.000000);
        Ks = vec3(0.500000, 0.500000, 0.500000);
        q = 20.0;

        //U = texcoords.x;
        //V = texcoords.y;
        //Kd = texture(TextureImage4, vec2(U,V)).rgb ;

        //Ka = vec3(1.000000, 1.000000, 1.000000);
        //Ks = vec3(0.500000, 0.500000, 0.500000);
        //q = 20.0;

    }
    else if (object_id == TRIANGULO)
    {
        U = texcoords.x;
        V = texcoords.y;
        Kd = texture(TextureImage5, vec2(U,V)).rgb ;

        Ka = vec3(1.000000, 1.000000, 1.000000);
        //Kd = vec3(0.640000, 0.640000, 0.640000);
        Ks = vec3(0.800000, 0.800000, 0.800000);
        q = 20.0;
    }
    else if (object_id == VACA)
    {
        vec4 c = (bbox_min + bbox_max) / 2.0;

        vec4 p_line = c + normalize(position_model - c);

        vec4 p_vec = p_line - c;

        float theta = atan(p_vec.x, p_vec.z);
        float phi = asin(p_vec.y);

        U = (theta+M_PI)/(2*M_PI);
        V = (phi + (M_PI/2))/M_PI;
        Kd = texture(TextureImage6, vec2(U,V)).rgb ;

        Ka = vec3(1.000000, 1.000000, 1.000000);
        Ks = vec3(0.500000, 0.500000, 0.500000);
        q = 20.0;
    }
    else if (object_id == ESFERA || object_id == ESFERA_BLINN)
    {
        U = texcoords.x;
        V = texcoords.y;
        Kd = texture(TextureImage7, vec2(U,V)).rgb ;

        Kd = vec3(1.0, 0.643, 0.0);
        Ka = vec3(1.000000, 1.000000, 1.000000);
        Ks = vec3(0.8, 0.8, 0.9);
        q = 40.0;
    }
    else if (object_id == CUBO)
    {

        float x = position_model.x;
        float y = position_model.y;
        float z = position_model.z;

        float absX = abs(x);
        float absY = abs(y);
        float absZ = abs(z);

        bool isXPositive = (x > 0) ? true : false;
        bool isYPositive = (y > 0) ? true : false;
        bool isZPositive = (z > 0) ? true : false;

        float maxAxis, uc, vc;

        // POSITIVE X
        if ((isXPositive) && (absX >= absY) && (absX >= absZ)) {
            maxAxis = absX;
            uc = -z;
            vc = y;
        }
        // NEGATIVE X
        if ((!(isXPositive)) && (absX >= absY) && (absX >= absZ)) {
            maxAxis = absX;
            uc = z;
            vc = y;
        }
        // POSITIVE Y
        if ((isYPositive) && (absY >= absX) && (absY >= absZ)) {
            maxAxis = absY;
            uc = x;
            vc = -z;
        }
        // NEGATIVE Y
        if ((!(isYPositive)) && (absY >= absX) && (absY >= absZ)) {
            maxAxis = absY;
            uc = x;
            vc = z;
        }
        // POSITIVE Z
        if ((isZPositive) && (absZ >= absX) && (absZ >= absY)) {
            maxAxis = absZ;
            uc = x;
            vc = y;
        }
        // NEGATIVE Z
        if ((!(isZPositive)) && (absZ >= absX) && (absZ >= absY)) {
            maxAxis = absZ;
            uc = -x;
            vc = y;
        }

        // Convert range from -1 to 1 to 0 to 1
        U = 0.5f * (uc / maxAxis + 1.0f);
        V = 0.5f * (vc / maxAxis + 1.0f);

        Kd = texture(TextureImage8, vec2(U,V)).rgb ;

        Ka = vec3(1.000000, 1.000000, 1.000000);
        Ks = vec3(0.500000, 0.500000, 0.500000);
        q = 20.0;
    }
    else if (object_id == ROSQUINHA_1)
    {
        U = texcoords.x;
        V = texcoords.y;
        Kd = texture(TextureImage9, vec2(U,V)).rgb ;

        Ka = vec3(1.000000, 1.000000, 1.000000);
        Ks = vec3(0.500000, 0.500000, 0.500000);
        q = 20.0;
    }
    else if (object_id == ROSQUINHA_2)
    {
        U = texcoords.x;
        V = texcoords.y;
        Kd = texture(TextureImage10, vec2(U,V)).rgb ;

        Ka = vec3(1.000000, 1.000000, 1.000000);
        Ks = vec3(0.500000, 0.500000, 0.500000);
        q = 20.0;
    }
    else if (object_id == LAMPADA)
    {
        U = texcoords.x;
        V = texcoords.y;
        if( cor_lampada == 1 )
            Kd = texture(TextureImage11, vec2(U,V)).rgb ;
        else if (cor_lampada == 2)
            Kd = texture(TextureImage12, vec2(U,V)).rgb ;
        else if (cor_lampada == 3)
            Kd = texture(TextureImage13, vec2(U,V)).rgb ;
        else if (cor_lampada == 4)
            Kd = texture(TextureImage14, vec2(U,V)).rgb ;
        else if (cor_lampada == 5)
            Kd = texture(TextureImage15, vec2(U,V)).rgb ;
        else if (cor_lampada == 6)
            Kd = texture(TextureImage16, vec2(U,V)).rgb ;


        Ka = vec3(1.000000, 1.000000, 1.000000);
        Ks = vec3(0.700000, 0.700000, 0.700000);
        q = 10.0;
    }
    else if (object_id == CHALEIRA_PLANA)
    {
        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float miny = bbox_min.y;
        float maxy = bbox_max.y;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        if (direcao_planar == 1){
            U = (position_model.x - minx)/(maxx-minx);
            V = (position_model.y - miny)/(maxy-miny);
        } else if (direcao_planar == 2){
            U = (position_model.x - minx)/(maxx-minx);
            V = (position_model.z - minz)/(maxz-minz);
        } else if (direcao_planar == 3){
            U = (position_model.y - miny)/(maxy-miny);
            V = (position_model.z - minz)/(maxz-minz);
        }

        Kd = texture(TextureImage17, vec2(U,V)).rgb ;

        Ka = vec3(1.000000, 1.000000, 1.000000);
        Ks = vec3(0.500000, 0.500000, 0.500000);
        q = 20.0;
    }
    else if (object_id == CHALEIRA_CUBICA)
    {

        float x = position_model.x;
        float y = position_model.y;
        float z = position_model.z;

        float absX = abs(x);
        float absY = abs(y);
        float absZ = abs(z);

        bool isXPositive = (x > 0) ? true : false;
        bool isYPositive = (y > 0) ? true : false;
        bool isZPositive = (z > 0) ? true : false;

        float maxAxis, uc, vc;

        // POSITIVE X
        if ((isXPositive) && (absX >= absY) && (absX >= absZ)) {
            maxAxis = absX;
            uc = -z;
            vc = y;
        }
        // NEGATIVE X
        if ((!(isXPositive)) && (absX >= absY) && (absX >= absZ)) {
            maxAxis = absX;
            uc = z;
            vc = y;
        }
        // POSITIVE Y
        if ((isYPositive) && (absY >= absX) && (absY >= absZ)) {
            maxAxis = absY;
            uc = x;
            vc = -z;
        }
        // NEGATIVE Y
        if ((!(isYPositive)) && (absY >= absX) && (absY >= absZ)) {
            maxAxis = absY;
            uc = x;
            vc = z;
        }
        // POSITIVE Z
        if ((isZPositive) && (absZ >= absX) && (absZ >= absY)) {
            maxAxis = absZ;
            uc = x;
            vc = y;
        }
        // NEGATIVE Z
        if ((!(isZPositive)) && (absZ >= absX) && (absZ >= absY)) {
            maxAxis = absZ;
            uc = -x;
            vc = y;
        }

        // Convert range from -1 to 1 to 0 to 1
        U = 0.5f * (uc / maxAxis + 1.0f);
        V = 0.5f * (vc / maxAxis + 1.0f);

        Kd = texture(TextureImage17, vec2(U,V)).rgb ;

        Ka = vec3(1.000000, 1.000000, 1.000000);
        Ks = vec3(0.500000, 0.500000, 0.500000);
        q = 20.0;
    }
    else if (object_id == CHALEIRA_ESFERICA)
    {
        vec4 c = (bbox_min + bbox_max) / 2.0;

        vec4 p_line = c + normalize(position_model - c);

        vec4 p_vec = p_line - c;

        float theta = atan(p_vec.x, p_vec.z);
        float phi = asin(p_vec.y);

        U = (theta+M_PI)/(2*M_PI);
        V = (phi + (M_PI/2))/M_PI;

        Kd = texture(TextureImage17, vec2(U,V)).rgb ;

        Ka = vec3(1.000000, 1.000000, 1.000000);
        Ks = vec3(0.500000, 0.500000, 0.500000);
        q = 20.0;
    }
    else if (object_id == CHALEIRA_CILINDRICA)
    {

        float theta = atan(position_model.x, position_model.z);
        float h = position_model.y;

        U = (theta + M_PI)/(2*M_PI);
        V = (h - bbox_min.y) / (bbox_max.y - bbox_min.y);

        Kd = texture(TextureImage17, vec2(U,V)).rgb ;

        Ka = vec3(1.000000, 1.000000, 1.000000);
        Ks = vec3(0.500000, 0.500000, 0.500000);
        q = 20.0;
    }
    else if (object_id == PLANO_GC_REAL)
    {
        U = texcoords.x;
        V = texcoords.y;
        Kd = texture(TextureImage18, vec2(U,V)).rgb ;

        Ka = vec3(1.000000, 1.000000, 1.000000);
        Ks = vec3(0.500000, 0.500000, 0.500000);
        q = 20.0;
    }
    else if (object_id == VETOR_ESTATICO)
    {
        U = texcoords.x;
        V = texcoords.y;
        Kd = texture(TextureImage16, vec2(U,V)).rgb ;

        Ka = vec3(1.000000, 1.000000, 1.000000);
        Ks = vec3(0.500000, 0.500000, 0.500000);
        q = 20.0;
    }
    else if (object_id == VETOR_MOVE)
    {
        U = texcoords.x;
        V = texcoords.y;
        Kd = texture(TextureImage13, vec2(U,V)).rgb ;

        Ka = vec3(1.000000, 1.000000, 1.000000);
        Ks = vec3(0.500000, 0.500000, 0.500000);
        q = 20.0;
    }
    else if (object_id == PLANO)
    {
        U = texcoords.x;
        V = texcoords.y;
        Kd = texture(TextureImage20, vec2(U,V)).rgb ;

        Ka = vec3(1.000000, 1.000000, 1.000000);
        Ks = vec3(0.500000, 0.500000, 0.500000);
        q = 20.0;
    }


    // Equação de Iluminação
    float lambert = max(0,dot(n,l));

    lambert_color = Kd * (lambert + 0.01);


    // Espectro da fonte de iluminação
    vec3 I = vec3(1.0, 1.0, 1.0);

    // Espectro da luz ambiente
    vec3 Ia = vec3(0.1, 0.1, 0.1);

    // Termo difuso utilizando a lei dos cossenos de Lambert
    vec3 lambert_diffuse_term = Kd*I*max(0.0,dot(n,l));

    // Termo ambiente
    vec3 ambient_term = Ka*Ia;

    // Termo especular utilizando o modelo de iluminação de Phong
    vec3 phong_specular_term  = Ks*I*pow(max(0.0, dot(r,v)),q);

    // Cor final do fragmento calculada com uma combinação dos termos difuso, especular, e ambiente.
    if(dot((normalize(p - spotlightPosition)), normalize(spotlightDirection)) < cos(M_PI/2.5)) // graus
        color = lambert_color;
    else
        color = lambert_diffuse_term + ambient_term + phong_specular_term ;

    if (object_id == ESFERA_BLINN){

        vec4 h = normalize(v + l);

        // Equação de Iluminação
        float lambert = max(0,dot(n,l));

        lambert_color = Kd * (lambert + 0.01);


        // Espectro da fonte de iluminação
        vec3 I = vec3(1.0, 1.0, 1.0);

        // Espectro da luz ambiente
        vec3 Ia = vec3(0.1, 0.1, 0.1);

        // Termo difuso utilizando a lei dos cossenos de Lambert
        vec3 lambert_diffuse_term = Kd*I*max(0.0,dot(n,l));

        // Termo ambiente
        vec3 ambient_term = Ka*Ia;

        // Termo especular utilizando o modelo de iluminação de Phong
        vec3 phong_specular_term  = Ks*I*pow(max(0.0, dot(n,h)),q);

        // Cor final do fragmento calculada com uma combinação dos termos difuso, especular, e ambiente.
        if(dot((normalize(p - spotlightPosition)), normalize(spotlightDirection)) < cos(M_PI/2.5)) // graus
            color = lambert_color;
        else
           color = lambert_diffuse_term + ambient_term + phong_specular_term ;

    }


    if (object_id == ESFERA_GOURAUD){
        color = cor_v;
    }


    // Cor final com correção gamma, considerando monitor sRGB.
    // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
    color = pow(color, vec3(1.0,1.0,1.0)/2.2);
}

