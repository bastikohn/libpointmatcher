#include "identity.h"

namespace pointmatcher
{
	void pybindIdentityEM(py::module& p_module)
	{
		using IdentityErrorMinimizer = ErrorMinimizersImpl<ScalarType>::IdentityErrorMinimizer;
		py::class_<IdentityErrorMinimizer, std::shared_ptr<IdentityErrorMinimizer>, ErrorMinimizer>(p_module, "IdentityErrorMinimizer")
		    .def(py::init<>())
		    .def_static("description", &IdentityErrorMinimizer::description)
		    .def("compute", &IdentityErrorMinimizer::compute, py::arg("mPts"));
	}
}