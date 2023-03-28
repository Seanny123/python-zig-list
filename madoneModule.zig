// boilerplate: import the Python C API
const py = @cImport({
    @cDefine("PY_SSIZE_T_CLEAN", {});
    @cInclude("Python.h");
});
const std = @import("std");

// boilerplate: more succinct names
const PyObject = py.PyObject;
const PyMethodDef = py.PyMethodDef;
const PyModuleDef = py.PyModuleDef;
const PyModuleDef_Base = py.PyModuleDef_Base;
const Py_BuildValue = py.Py_BuildValue;
const PyModule_Create = py.PyModule_Create;
const PyArg_ParseTuple = py.PyArg_ParseTuple;

// actual pretty Zig function
fn addOne(arr: []f64) void {
    for (arr, 0..) |val, index| {
        arr[index] = val + 1.0;
    }
}

// Zig-wrapping-C boilerplate signature
fn addOneList(self: [*c]PyObject, args: [*c]PyObject) callconv(.C) [*]PyObject {
    _ = self;

    // initialize memory allocation
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // read in the list from Python

    // get size of list from passed args
    var float_list: [*c]PyObject = undefined;
    var parse_res = PyArg_ParseTuple(args, "O", &float_list);

    if (parse_res == 0) return Py_BuildValue("");

    const pr_length: usize = @intCast(usize, py.PyObject_Length(float_list));
    if (pr_length < 0) return Py_BuildValue("");

    // allocate memory for the list
    const arr = allocator.alloc(f64, pr_length) catch unreachable;

    // convert each list item to Zig-compatible floats
    for (0..pr_length) |index| {
        const item: [*c]PyObject = py.PyList_GetItem(float_list, @intCast(isize, index));
        if (py.PyFloat_Check(item) != 0)
            arr[index] = 0.0;
        arr[index] = py.PyFloat_AsDouble(item);
    }

    addOne(arr);

    // output new list to Python by convert each slice item to Python-compatible floats
    var list: [*c]PyObject = py.PyList_New(@intCast(isize, pr_length));
    for (0..pr_length) |index| {
        _ = py.PyList_SetItem(list, @intCast(isize, index), Py_BuildValue("f", arr[index]));
    }

    return list;
}


// boilerplate to expose the Python module
var Methods = [_]PyMethodDef{PyMethodDef{
    .ml_name = "addone",
    .ml_meth = addOneList,
    .ml_flags = @as(c_int, 1),
    .ml_doc = null,
}};

var module = PyModuleDef{
    .m_base = PyModuleDef_Base{
        .ob_base = PyObject{
            .ob_refcnt = 1,
            .ob_type = null,
        },
        .m_init = null,
        .m_index = 0,
        .m_copy = null,
    },
    .m_name = "madone",
    .m_doc = null,
    .m_size = -1,
    .m_methods = &Methods,
    .m_slots = null,
    .m_traverse = null,
    .m_clear = null,
    .m_free = null,
};

pub export fn PyInit_madone() [*]PyObject {
    return PyModule_Create(&module);
}
