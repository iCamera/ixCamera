//
//  KNCVImageRender.m
//  ixCamera
//
//  Created by ken on 13. 4. 9..
//  Copyright (c) 2013년 cyh3813. All rights reserved.
//

#import "KNCVImageRender.h"
#import <OpenGLES/ES2/gl.h>

#pragma mark - SHADER
#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

NSString *const vertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec2 texcoord;
 uniform mat4 modelViewProjectionMatrix;
 varying vec2 v_texcoord;
 
 void main()
 {
     gl_Position = modelViewProjectionMatrix * position;
     v_texcoord = texcoord.xy;
 }
);

NSString *const fragmentShaderString = SHADER_STRING
(
 varying highp vec2 v_texcoord;
 uniform sampler2D s_texture_y;
 uniform sampler2D s_texture_u;
 uniform sampler2D s_texture_v;
 
 void main()
 {
     gl_FragColor = texture2D(videoFrame, textureCoordinate);
 }
);


@interface KNCVImageRender () {
    
    GLuint* videoFrameTexture;
}
@end


@implementation KNCVImageRender

- (id)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    if (self) {
    
        CAEAGLLayer *eaglLayer = (CAEAGLLayer*)[self layer];
        [eaglLayer setOpaque: YES];
        [eaglLayer setFrame: [self bounds]];
        [eaglLayer setContentsScale: 2.0];
        glContext = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
        if(!glContext || ![EAGLContext setCurrentContext: glContext])   {
            [self release];
            return nil;
        }
        
        //endable 2D textures
        glEnable(GL_TEXTURE_2D);
        
        //generates the frame and render buffers at the pointer locations of the frameBuffer and renderBuffer variables
        glGenFramebuffers(1,  &frameBuffer);
        glGenRenderbuffers(1, &renderBuffer);
        
        //binds the frame and render buffers, they can now be modified or consumed by later openGL calls
        glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
        
        //generate storeage for the renderbuffer (Wouldn't be used for offscreen rendering, glRenderbufferStorage() instead)
        [glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable: eaglLayer];
        
        //attaches the renderbuffer to the framebuffer
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
        
        //sets up the coordinate system
        glViewport(0, 0, frame.size.width, frame.size.height);
        
        //|||||||||||||||--Remove this stuff later--||||||||||||||//
        
        //create the vertex and fragement shaders
        GLint vertexShader, fragmentShader;
        vertexShader = glCreateShader(GL_VERTEX_SHADER);
        fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
        
        //get their source paths, and the source, store in a char array
        const GLchar *vertexSource = (GLchar *)[vertexShaderString UTF8String];
        const GLchar *fragmentSource = (GLchar *)[fragmentShaderPath UTF8String];
        
        NSLog(@"\n--- Vertex Source ---\n%s\n--- Fragment Source ---\n%s", vertexSource, fragmentSource);
        
        //associate the source strings with each shader
        glShaderSource(vertexShader, 1, &vertexSource, NULL);
        glShaderSource(fragmentShader, 1, &fragmentSource, NULL);
        
        //compile the vertex shader, check for errors
        glCompileShader(vertexShader);
        GLint compiled;
        glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &compiled);
        if(!compiled)   {
            GLint infoLen = 0;
            glGetShaderiv(vertexShader, GL_INFO_LOG_LENGTH, &infoLen);
            GLchar *infoLog = (GLchar *)malloc(sizeof(GLchar) * infoLen);
            glGetShaderInfoLog(vertexShader, infoLen, NULL, infoLog);
            NSLog(@"\n--- Vertex Shader Error ---\n%s", infoLog);
            free(infoLog);
        }
        
        //compile the fragment shader, check for errors
        glCompileShader(fragmentShader);
        glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &compiled);
        if(!compiled)   {
            GLint infoLen = 0;
            glGetShaderiv(fragmentShader, GL_INFO_LOG_LENGTH, &infoLen);
            GLchar *infoLog = (GLchar *)malloc(sizeof(GLchar) * infoLen);
            glGetShaderInfoLog(fragmentShader, infoLen, NULL, infoLog);
            NSLog(@"\n--- Fragment Shader Error ---\n%s", infoLog);
            free(infoLog);
        }
        
        //create a program and attach both shaders
        testProgram = glCreateProgram();
        glAttachShader(testProgram, vertexShader);
        glAttachShader(testProgram, fragmentShader);
        
        //bind some attribute locations...
        glBindAttribLocation(testProgram, 0, "position");
        glBindAttribLocation(testProgram, 1, "inputTextureCoordinate");
        
        //link and use the program, make sure it worked :P
        glLinkProgram(testProgram);
        glUseProgram(testProgram);
        
        GLint linked;
        glGetProgramiv(testProgram, GL_LINK_STATUS, &linked);
        if(!linked) {
            GLint infoLen = 0;
            glGetProgramiv(testProgram, GL_INFO_LOG_LENGTH, &infoLen);
            GLchar *infoLog = (GLchar *)malloc(sizeof(GLchar) * infoLen);
            glGetProgramInfoLog(testProgram, infoLen, NULL, infoLog);
            NSLog(@"%s", infoLog);
            free(infoLog);
        }
        
        videoFrameUniform = glGetUniformLocation(testProgram, "videoFrame");
        
    }
    return self;
}

- (void)render:(CVImageBufferRef)pixelBuffer {
    
    int bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
    int bufferWidth = CVPixelBufferGetWidth(pixelBuffer);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // This is necessary for non-power-of-two textures
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    //set the image for the currently bound texture
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, bufferWidth, bufferHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, CVPixelBufferGetBaseAddress(pixelBuffer));
    
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    static const GLfloat textureVertices[] = {
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f,  1.0f,
        0.0f,  0.0f,
    };
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, videoFrameTexture);
    
    // Update uniform values
    glUniform1i(videoFrameUniform, 0);
    
    glVertexAttribPointer(0, 2, GL_FLOAT, 0, 0, squareVertices);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, 0, 0, textureVertices);
    glEnableVertexAttribArray(1);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
}
@end
