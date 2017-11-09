module Hello

using GLVisualize, GeometryTypes, GLWindow, GLFW, GLAbstraction, Reactive, ModernGL, Colors

using GLAbstraction: isa_gl_struct
using GLWindow: loadshader, rcpframe

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    window = create_glcontext(
        "GLVisualize",
        resolution = (800, 600),
        windowhints = GLWindow.standard_window_hints(),
        contexthints = GLWindow.standard_context_hints(3, 3),
    )
    callbacks = GLWindow.standard_callbacks()
    #create standard signals
    signal_dict = GLWindow.register_callbacks(window, callbacks)
    @materialize window_position, window_size, hasfocus = signal_dict
    @materialize framebuffer_size, cursor_position = signal_dict
    window_area = map(SimpleRectangle,
        Signal(Vec(0,0)),
        framebuffer_size
    )
    signal_dict[:window_area] = window_area
    # seems to be necessary to set this as early as possible
    fb_size = value(framebuffer_size)
    glViewport(0, 0, fb_size...)
    # GLFW uses different coordinates from OpenGL, and on osx, the coordinates
    # are not in pixel coordinates
    # we coorect them to always be in pixel coordinates with 0,0 in left down corner
    signal_dict[:mouseposition] = Signal(Vec(0.0, 0.0))
    # signal_dict[:mouseposition] = const_lift(GLWindow.corrected_coordinates,
    #     Signal(window_size), Signal(framebuffer_size), cursor_position
    # )
    signal_dict[:mouse2id] = Signal(GLWindow.SelectionID{Int}(-1, -1))
    GLFW.SwapInterval(0) # deactivating vsync seems to make everything quite a bit smoother
    color = RGBA(1f0, 1f0, 1f0, 1f0)
    lazyshader = LazyShader(
        loadshader("fullscreen.vert"),
        loadshader("fxaa.frag")
    )
    buffersize = (800, 600)
    color_luma = Texture(RGBA{N0f8}, buffersize, minfilter=:linear, x_repeat=:clamp_to_edge)
    data = Dict{Symbol, Any}(
        :color_texture => color_luma,
        :RCPFrame => map(rcpframe, Signal(Vec2f0(buffersize)))
    )
    p = gl_convert(lazyshader, data)
    ctx = GLWindow.GLContext(window, GLWindow.GLFramebuffer(framebuffer_size), true)
    screen = GLWindow.Screen(
        :GLVisualize, window_area, nothing,
        Screen[], signal_dict,
        (), false, true, color, (0f0, color),
        Dict{Symbol, Any}(),
        ctx
    )
    signal_dict[:mouseinside] = const_lift(isinside, screen, signal_dict[:mouseposition])

    GLVisualize.add_screen(screen)

    GLWindow.add_complex_signals!(screen) #add the drag events and such
    GLFW.MakeContextCurrent(GLWindow.nativewindow(screen))
    window = screen
    _view(visualize((Sphere(Point3f0(0), 0.1f0), rand(Point3f0, 100))))
    GLWindow.poll_glfw()
    while isopen(window)
        GLWindow.poll_glfw()
        GLWindow.render_frame(window)
        GLWindow.swapbuffers(window)
    end
    GLWindow.destroy!(window)
    return 0
end

end
