#!/bin/bash
# Intel based : https://software.intel.com/en-us/articles/intel-architecture-and-processor-identification-with-cpuid-model-and-family-numbers
declare -A CPUID
CPUID["0655"]="Skylake"
CPUID["064F"]="Broadwell"
CPUID["0647"]="Broadwell"
CPUID["0657"]="KnightsLanding"
CPUID["063F"]="Haswell"
CPUID["0646"]="Haswell"
CPUID["063A"]="IvyBridge"
CPUID["062A"]="SandyBridge"
CPUID["062D"]="SandyBridge"
CPUID["0625"]="Westmere"
CPUID["062C"]="Westmere"
CPUID["062F"]="Westmere"
CPUID["061E"]="Nehalem"
CPUID["061A"]="Nehalem"
CPUID["062E"]="Nehalem"
CPUID["0617"]="Penryn"
CPUID["061D"]="Penryn"
CPUID["060F"]="Merom"
CPUID["1701"]="Zen"

function identify_uarch() {
    local cpu_family=$(lscpu | grep "CPU family:" | awk '{printf "%02X",$3}')
    local cpu_model=$(lscpu | grep "Model:" | awk '{printf "%02X",$2}')
    local architecture=$(echo ${CPUID[${cpu_family}${cpu_model}]})
    if [ -z $architecture ]; then
        echo "Your CPU model with code ${cpuhex} is not recognised."
    else
        export ARCHITECTURE=$architecture
    fi
}

function identify_os_name_and_version() {
    # OS release and Service pack discovery
    local distro_name=$(lsb_release -si)
    local distro_version=$(lsb_release -sr)

    if [[ "${distro_name}" == "openSUSE project" ]]; then
        distro_name="openSUSE"
    elif [[ "${distro_name}" == "SUSE LINUX" ]]; then
        distro_name="SUSE"
    elif [[ "${distro_name}" == "RedHatEnterpriseServer" ]]; then
        distro_name="RHEL"
    fi

    if [[ -z "${distro_name}" ]]; then
        distro_name=$(uname -s)
    fi
    if [[ -z "${distro_version}" ]]; then
        distro_version=$(uname -m)
    fi

    export OS_NAME=${distro_name}
    export OS_VERSION=${distro_version}
}

identify_uarch
identify_os_name_and_version

export ARCHITECTURE=${ARCHITECTURE}
export OS_VERSION=${OS_VERSION}
export OS_NAME=${OS_NAME}

if [ -z $OS_NAME ] || [ -z $OS_VERSION ]; then
    echo "OS_NAME and/or OS_VERSION are empty! Exit."
fi

#if [ -z "${LMOD_DIR}" ]; then
#    echo "Lmod not detected. Can not continue."
#fi

#module unuse /opt/ohpc/pub/modulefiles
export SOFTWARE_ROOT="/mnt/shared/home/easybuild"
export EASYBUILD_PREFIX=${SOFTWARE_ROOT}/arch/${OS_NAME}/${OS_VERSION}/${ARCHITECTURE}
export EASYBUILD_INSTALLPATH=${EASYBUILD_PREFIX}
export EASYBUILD_SOURCEPATH=${SOFTWARE_ROOT}/sources
export EASYBUILD_TMP_LOGDIR=${SOFTWARE_ROOT}/tmp
export EASYBUILD_BUILDPATH=/dev/shm/$USER

#if [[ -e ${SOFTWARE_ROOT}/common/modules/all ]]; then
#    module use ${SOFTWARE_ROOT}/common/modules/all
#else
#    echo "Easybuild common module path is not available"
#fi

if [[ -e ${EASYBUILD_PREFIX}/modules/all ]]; then
    module use ${EASYBUILD_PREFIX}/modules/all
else
    echo "Applications ${EASYBUILD_PREFIX} module path is not available"
fi
